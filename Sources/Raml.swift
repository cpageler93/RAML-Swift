import Foundation
import Yaml

enum RAMLError: Error {
    case yamlParsingError(message: String)
    case invalidRAMLVersion(message: String)
    case ramlParsingError(message: String)
}

public class RAML {
    
    public var ramlVersion: String = ""
    
    public var title: String = ""
    public var description: String?
    public var version: String?
    public var baseURI: String?
//    baseUriParameters
    public var protocols: Protocols?
//    mediaType
    public var documentation: [DocumentationEntry]?
//    schemas
//    types
//    traits
//    resourceTypes
//    annotationTypes
//    securitySchemes
//    securedBy
//    uses
    
    static let keyWithEmptyValueFix = "RAMLEMPTYVALUEFIX"
    
    public init(_ string: String) throws {
        let yamlString = cleanedYamlString(from: string)
        
        // validate version
        let ramlVersion = try validateRamlVersion(string: yamlString)
        self.ramlVersion = ramlVersion
        
        // parse string to yaml
        let dirtyYaml = try parsedYAMLFromString(yamlString)
        
        // clean yaml from "key without values"-fix
        let yaml = cleanedYaml(dirtyYaml)
        
        // parse root raml
        try parseRoot(yaml)
    }
    
    public struct Protocols: OptionSet {
        public init(rawValue: Protocols.RawValue) {
            self.rawValue = rawValue
        }
        public let rawValue: Int
        
        static let http  = Protocols(rawValue: 1 << 0)
        static let https = Protocols(rawValue: 1 << 1)
    }
    
    public class DocumentationEntry {
        public var title: String
        public var content: String
        
        init(title: String, content: String) {
            self.title = title
            self.content = content
        }
    }
}

// MARK: Parsing
extension RAML {
    
    fileprivate func validateRamlVersion(string: String) throws -> String {
        guard let firstLine = string.components(separatedBy: "\n").first else { throw RAMLError.invalidRAMLVersion(message: "string has no first line") }
        let ramlPrefix = "#%RAML "
        guard firstLine.hasPrefix(ramlPrefix) else { throw RAMLError.invalidRAMLVersion(message: "first line must look like this `#%RAML <version>`") }
        let ramlVersion = firstLine.substring(from: ramlPrefix.endIndex)
        guard ramlVersion == "1.0" else { throw RAMLError.invalidRAMLVersion(message: "only RAML Version 1.0 is supported") }
        return ramlVersion
    }
    
    fileprivate func parsedYAMLFromString(_ string: String) throws -> Yaml {
        do {
            let parsedYaml = try Yaml.load(string)
            return parsedYaml
        } catch {
            throw RAMLError.yamlParsingError(message: error.localizedDescription)
        }
    }
    
    fileprivate func parseRoot(_ yaml: Yaml) throws {
        guard let yamlTitle = yaml["title"].string else { throw RAMLError.ramlParsingError(message: "title is required") }
        
        self.title = yamlTitle
        self.description = yaml["description"].string
        self.version = yaml["version"].string
        self.baseURI = yaml["baseUri"].string
        
        if let protocolsYaml = yaml["protocols"].array {
            var protocols: Protocols = []
            for protocolYaml in protocolsYaml {
                guard let protocolString = protocolYaml.string else {
                    throw RAMLError.ramlParsingError(message: "protocol must be kind of string")
                }
                
                switch protocolString.uppercased() {
                case "HTTP": protocols.insert(.http)
                case "HTTPS": protocols.insert(.https)
                default:
                    throw RAMLError.ramlParsingError(message: "protocol `\(protocolString)` not supported")
                }
            }
            self.protocols = protocols
        }
        
        // documentation
        if let yamlDocumentationEntries = yaml["documentation"].array {
            var documentation: [DocumentationEntry] = []
            
            for (index, yamlDocumentationEntry) in yamlDocumentationEntries.enumerated() {
                guard let title = yamlDocumentationEntry["title"].string else {
                    throw RAMLError.ramlParsingError(message: "`title` not set in documentation entry \(index)")
                }
                guard let content = yamlDocumentationEntry["content"].string else {
                    throw RAMLError.ramlParsingError(message: "`content` not set in documentation entry \(index)")
                }
                let documentationEntry = DocumentationEntry(title: title, content: content)
                documentation.append(documentationEntry)
            }
            
            self.documentation = documentation
        }
    }
}


// MARK: YAML Cleanup
extension RAML {
    fileprivate func cleanedYamlString(from string: String) -> String {
        return cleanKeysWithoutValues(from: string)
    }
    
    /// we need to clean keys without values for our purpose because our yaml parser cannot handle that
    private func cleanKeysWithoutValues(from string: String) -> String {
        // go line by line
        do {
            let lines = string.components(separatedBy: "\n")
            let keyValueRegularExpression = try NSRegularExpression(pattern: "(.*):( *)$")
            
            // create new lines
            var newLines: [String] = []
            
            // enumerate lines
            for (index, line) in lines.enumerated() {
                
                // find all key without explicit value
                if keyValueRegularExpression.matches(in: line, range: NSMakeRange(0, line.count)).first != nil {
                    
                    var addLineWithEmptyValueFix = true
                    
                    // lets if the next line contains a possible child
                    if let nextLine = lines[safe: index+1] {
                        let indentOfCurrentLine = try indentationOf(line: line)
                        let indentOfNextLine = try indentationOf(line: nextLine)
                        let hasChild = indentOfNextLine > indentOfCurrentLine
                        addLineWithEmptyValueFix = !hasChild
                    }
                    
                    if addLineWithEmptyValueFix {
                        newLines.append("\(line) \(RAML.keyWithEmptyValueFix)")
                    } else {
                        newLines.append(line)
                    }
                } else {
                    // ignore line with value
                    newLines.append(line)
                }
            }
            
            // join new string and return
            let cleanedString = newLines.joined(separator: "\n")
            return cleanedString
        } catch {
            
        }
        
        // something went wrong.. just return the original string
        return string
    }
    
    private func indentationOf(line: String) throws -> Int {
        let expr = try NSRegularExpression(pattern: "( *)(.*)")
        guard let match = expr.matches(in: line, range: NSMakeRange(0, line.count)).first else { return 0 }
        return match.rangeAt(1).length
    }
    
    fileprivate func cleanedYaml(_ yaml: Yaml) -> Yaml {
        return cleanYamlFromKeysWithoutValuesFix(yaml)
    }
    
    private func cleanYamlFromKeysWithoutValuesFix(_ yaml: Yaml) -> Yaml {
        if let string = yaml.string {
            if string.contains(RAML.keyWithEmptyValueFix) {
                return Yaml(nilLiteral: ())
            } else {
                return Yaml(stringLiteral: string)
            }
        } else if let array = yaml.array {
            var newArray: [Yaml] = []
            for entry in array {
                let cleaned = cleanYamlFromKeysWithoutValuesFix(entry)
                newArray.append(cleaned)
            }
            return Yaml(array: newArray)
        } else if let dictionary = yaml.dictionary {
            var newDictionary: [Yaml: Yaml] = [:]
            for (key, value) in dictionary {
                newDictionary[key] = cleanYamlFromKeysWithoutValuesFix(value)
            }
            return Yaml(dictionary: newDictionary)
        } else {
            return yaml
        }
    }
}

extension Yaml {
    public init(array elements: [Yaml]) {
        self = .array(elements)
    }
    public init(dictionary elements: [Yaml: Yaml]) {
        var dictionary = [Yaml: Yaml]()
        for (k, v) in elements {
            dictionary[k] = v
        }
        self = .dictionary(dictionary)
    }
}

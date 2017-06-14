import Foundation
import Yaml

enum RAMLError: Error {
    case yamlParsingError(message: String)
    case invalidRAMLVersion(message: String)
    case ramlParsingError(message: String)
}

public class RAML {
    
    public var version: String = ""
    public var title: String = ""
    
    let keyWithEmptyValueFix = "RAMLEMPTYVALUEFIX"
    
    public init(_ string: String) throws {
        let cleanedYamlSring = cleanedYamlString(from: string)
        
        // validate version
        let ramlVersion = try validateRamlVersion(string: cleanedYamlSring)
        self.version = ramlVersion
        
        // parse string to yaml
        let yaml = try parsedYAMLFromString(cleanedYamlSring)
        
        // parse root raml
        try parseRoot(yaml)
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
        guard let yamlTitle = yaml["title"].string else { throw RAMLError.yamlParsingError(message: "title is required") }
        
        self.title = yamlTitle
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
                        newLines.append("\(line) \(keyWithEmptyValueFix)")
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
}

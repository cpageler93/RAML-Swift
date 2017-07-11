//
//  Raml+LoadFromString.swift
//  RAML
//
//  Created by Christoph Pageler on 24.06.17.
//

import Foundation
import Yaml
import PathKit

internal extension RAML {
    
    // MARK: - Internal
    
    internal func contentFromFile(path: Path) throws -> String {
        if !path.exists { throw RAMLError.invalidFile(atPath: path.string) }
        return try path.read(String.Encoding.utf8)
    }
    
    internal func yamlFromString(_ string: String ) throws -> Yaml {
        let yamlString = cleanedYamlString(from: string)
        
        // parse string to yaml
        let dirtyYaml = try parsedYAMLFromString(yamlString)
        
        // clean yaml from "key without values"-fix
        return cleanedYaml(dirtyYaml)
    }
    
    internal func loadRamlRootFromString(_ string: String) throws {
        // validate version
        let ramlVersion = try validateRamlVersion(string: string)
        self.ramlVersion = ramlVersion
        
        // parse yaml from string
        let yaml = try yamlFromString(string)
        
        // parse root raml
        try parseRoot(yaml)
    }
    
    internal func validateRamlFragmentIdentifier(_ fragmentIdentifier: String,
                                                 inString: String) throws {
        guard let firstLine = inString.components(separatedBy: "\n").first else { return }
        let ramlPrefix = "#%RAML 1.0"
        guard firstLine.hasPrefix(ramlPrefix) else { return }
        let foundFragmentIdentifier = firstLine.substring(from: ramlPrefix.endIndex).trimmingCharacters(in: CharacterSet.whitespaces)
        guard foundFragmentIdentifier.characters.count > 0 else { throw RAMLError.ramlParsingError(.missingFragmentIdentifier) }
        if fragmentIdentifier != foundFragmentIdentifier {
            throw RAMLError.ramlParsingError( .invalidFragmentIdentifier(invalid: foundFragmentIdentifier,
                                                                         valid: fragmentIdentifier))
        }
    }
    
    // MARK: - Private
    
    fileprivate func validateRamlVersion(string: String) throws -> String {
        guard let firstLine = string.components(separatedBy: "\n").first else { throw RAMLError.ramlParsingError(.stringIsEmpty) }
        let ramlPrefix = "#%RAML "
        guard firstLine.hasPrefix(ramlPrefix) else { throw RAMLError.ramlParsingError(.invalidVersion) }
        let ramlVersion = firstLine.substring(from: ramlPrefix.endIndex)
        guard ramlVersion == "1.0" else { throw RAMLError.ramlParsingError(.invalidVersion) }
        return ramlVersion
    }
    
    fileprivate func parsedYAMLFromString(_ string: String) throws -> Yaml {
        do {
            let parsedYaml = try Yaml.load(string)
            return parsedYaml
        } catch {
            throw RAMLError.yamlParsingError(error)
        }
    }

    // MARK: YAML Cleanup
    
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

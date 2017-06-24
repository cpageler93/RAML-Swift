//
//  Raml+LoadFromString.swift
//  RAML
//
//  Created by Christoph Pageler on 24.06.17.
//

import Foundation
import Yaml

extension RAML {
    internal func loadRamlFromString(_ string: String) throws {
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

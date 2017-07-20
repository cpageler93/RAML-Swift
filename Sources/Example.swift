//
//  TypeExample.swift
//  RAML
//
//  Created by Christoph Pageler on 24.06.17.
//

import Foundation
import Yaml

public class Example {
    
    public var identifier: String
    public var displayName: String?
    public var description: String?
    public var annotations: [Annotation]?
    public var value: [Yaml: Yaml]?
    public var strict: Bool?
    
    public init(identifier: String) {
        self.identifier = identifier
    }
    
}


// MARK: Parsing Example
internal extension RAML {
    
    internal func parseExampleOrExamples(yamlDict: [Yaml: Yaml]?) throws -> [Example]? {
        guard let yamlDict = yamlDict else { return nil }
        if let examplesYaml = yamlDict["examples"]?.dictionary {
            return try parseExamples(dict: examplesYaml)
        }
        
        if let yamlDict = yamlDict["example"] {
            return try parseExample(yaml: yamlDict)
        }
        
        return nil
    }
    
    private func parseExample(yaml: Yaml) throws -> [Example]? {
        switch yaml {
        case .array(let yamlArray):
            return try parseExamples(array: yamlArray)
        case .dictionary:
            return try [parseExample(identifier: "Example 1", yaml: yaml)]
        default:
            return nil
        }
    }
    
    private func parseExamples(array: [Yaml]) throws -> [Example] {
        var examples: [Example] = []
        for (index, exampleYaml) in array.enumerated() {
            let example = try parseExample(identifier: "Example \(index+1)", yaml: exampleYaml)
            examples.append(example)
        }
        return examples
    }
    
    private func parseExamples(dict: [Yaml: Yaml]) throws -> [Example] {
        var examples: [Example] = []
        for (key, value) in dict {
            guard let keyString = key.string else {
                throw RAMLError.ramlParsingError(.invalidDataType(for: "Example Key", mustBeKindOf: "String"))
            }
            let example = try parseExample(identifier: keyString, yaml: value)
            examples.append(example)
        }
        return examples
    }
    
    private func parseExample(identifier: String, yaml: Yaml) throws -> Example {
        let example = Example(identifier: identifier)
        
        if let valueDict = yaml["value"].dictionary {
            example.displayName = yaml["displayName"].string
            example.description = yaml["description"].string
            example.annotations = try parseAnnotations(ParseInput(yaml))
            example.strict      = yaml["strict"].bool
            example.value = valueDict
        } else {
            example.value = yaml.dictionary
        }
        
        return example
    }
    
}


public protocol HasExamples {
    
    var examples: [Example]? { get set }
    
}


public extension HasExamples {
    
    public func exampleWith(identifier: String) -> Example? {
        for example in examples ?? [] {
            if example.identifier == identifier {
                return example
            }
        }
        return nil
    }
    
    public func hasExampleWith(identifier: String) -> Bool {
        return exampleWith(identifier: identifier) != nil
    }
    
}

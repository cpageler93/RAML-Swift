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
    
    internal func parseExamples(_ input: ParseInput) throws -> [Example]? {
        guard let yaml = input.yaml else { return nil }
        
        switch yaml {
        case .dictionary(let yamlDict):
            return try parseExamples(dict: yamlDict)
        default:
            return nil
        }
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
        
        example.displayName = yaml["displayName"].string
        example.description = yaml["description"].string
        example.annotations = try parseAnnotations(ParseInput(yaml))
        example.value       = yaml["value"].dictionary
        example.strict      = yaml["strict"].bool
        
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

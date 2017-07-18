//
//  Trait.swift
//  RAML
//
//  Created by Christoph Pageler on 30.06.17.
//

import Foundation
import Yaml
import PathKit

public class TraitDefinition: HasHeaders {
    
    public var name: String
    public var usage: String?
    public var description: String?
    
    public var headers: [Header]?
    // queryParameters
    
    public init(name: String) {
        self.name = name
    }
}


// MARK: Trait Parsing
internal extension RAML {
    
    internal func parseTraitDefinitions(_ input: ParseInput) throws -> [TraitDefinition]? {
        guard let yaml = input.yaml else { return nil }
        
        switch yaml {
        case .dictionary(let yamlDict):
            return try parseTraitDefinitions(dict: yamlDict, parentFilePath: input.parentFilePath)
        case .string(let yamlString):
            let yaml = try parseTraitFromIncludeString(yamlString, parentFilePath: input.parentFilePath)
            guard let traitsDict = yaml.dictionary else {
                throw RAMLError.ramlParsingError(.invalidInclude)
            }
            return try parseTraitDefinitions(dict: traitsDict, parentFilePath: input.parentFilePath)
        default:
            return nil
        }
        
    }
    
    private func parseTraitDefinitions(dict: [Yaml: Yaml], parentFilePath: Path?) throws -> [TraitDefinition] {
        var traitDefinitions: [TraitDefinition] = []
        
        for (key, value) in dict {
            guard let keyString = key.string else {
                throw RAMLError.ramlParsingError(.invalidDataType(for: "Trait Key",
                                                                  mustBeKindOf: "String"))
            }
            let traitDefinition = try parseTraitDefinition(name: keyString, yaml: value, parentFilePath: parentFilePath)
            traitDefinitions.append(traitDefinition)
        }
        
        return traitDefinitions
    }
    
    private func parseTraitDefinition(name: String, yaml: Yaml, parentFilePath: Path?) throws -> TraitDefinition {
        let traitDefinition = TraitDefinition(name: name)
        
        switch yaml {
        case .dictionary(let yamlDict):
            traitDefinition.headers = try parseHeaders(ParseInput(yamlDict["headers"], parentFilePath))
        case .string(let yamlString):
            let yamlFromInclude = try parseTraitFromIncludeString(yamlString, parentFilePath: parentFilePath)
            return try parseTraitDefinition(name: name,
                                            yaml: yamlFromInclude,
                                            parentFilePath: parentFilePath)
        default:
            throw RAMLError.ramlParsingError(.failedParsingTraitDefinition)
        }
        
        return traitDefinition
    }
    
    private func parseTraitFromIncludeString(_ includeString: String, parentFilePath: Path?) throws -> Yaml {
        try testInclude(includeString)
        guard let parentFilePath = parentFilePath else {
            throw RAMLError.ramlParsingError(.invalidInclude)
        }
        return try parseYamlFromIncludeString(includeString,
                                              parentFilePath: parentFilePath,
                                              permittedFragmentIdentifier: "Trait")
    }
    
}


public protocol HasTraitDefinitions {
    
    var traitDefinitions: [TraitDefinition]? { get set }
    
}


public extension HasTraitDefinitions {
    
    public func traitDefinitionWith(name: String) -> TraitDefinition? {
        for traitDefinition in traitDefinitions ?? [] {
            if traitDefinition.name == name {
                return traitDefinition
            }
        }
        return nil
    }
    
    public func hasTraitDefinitionWith(name: String) -> Bool {
        return traitDefinitionWith(name: name) != nil
    }
    
}

//
//  Trait.swift
//  RAML
//
//  Created by Christoph Pageler on 30.06.17.
//

import Foundation
import Yaml

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
    
    internal func parseTraitDefinitions(yaml: Yaml?) throws -> [TraitDefinition]? {
        guard let yaml = yaml else { return nil }
        
        switch yaml {
        case .dictionary(let yamlDict):
            return try parseTraitDefinitions(dict: yamlDict)
        case .string(let yamlString):
            let yaml = try parseTraitFromIncludeString(yamlString)
            guard let traitsDict = yaml.dictionary else {
                throw RAMLError.ramlParsingError(.invalidInclude)
            }
            return try parseTraitDefinitions(dict: traitsDict)
        default:
            return nil
        }
        
    }
    
    internal func parseTraitDefinitions(dict: [Yaml: Yaml]) throws -> [TraitDefinition] {
        var traitDefinitions: [TraitDefinition] = []
        
        for (key, value) in dict {
            guard let keyString = key.string else {
                throw RAMLError.ramlParsingError(.invalidDataType(for: "Trait Key",
                                                                  mustBeKindOf: "String"))
            }
            let traitDefinition = try parseTraitDefinition(name: keyString, yaml: value)
            traitDefinitions.append(traitDefinition)
        }
        
        return traitDefinitions
    }
    
    private func parseTraitDefinition(name: String, yaml: Yaml) throws -> TraitDefinition {
        let traitDefinition = TraitDefinition(name: name)
        
        switch yaml {
        case .dictionary(let yamlDict):
            traitDefinition.headers = try parseHeaders(yaml: yamlDict["headers"])
        case .string(let yamlString):
            let yamlFromInclude = try parseTraitFromIncludeString(yamlString)
            return try parseTraitDefinition(name: name,
                                            yaml: yamlFromInclude)
        default:
            throw RAMLError.ramlParsingError(.failedParsingTraitDefinition)
        }
        
        return traitDefinition
    }
    
    internal func parseTraitFromIncludeString(_ includeString: String) throws -> Yaml {
        try testInclude(includeString)
        return try parseYamlFromIncludeString(includeString,
                                              parentFilePath: try directoryOfInitialFilePath(),
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

//
//  Trait.swift
//  RAML
//
//  Created by Christoph Pageler on 30.06.17.
//

import Foundation
import Yaml

public class TraitDefinition: HasResourceHeaders {
    
    public var name: String
    public var usage: String?
    public var description: String?
    
    public var headers: [ResourceHeader]?
    // queryParameters
    
    public init(name: String) {
        self.name = name
    }
}


// Trait Parsing
extension RAML {
    // TODO: consider includes
    
    internal func parseTraitDefinitions(_ yaml: [Yaml: Yaml]) throws -> [TraitDefinition] {
        var traitDefinitions: [TraitDefinition] = []
        
        for (key, value) in yaml {
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
        
        if let yamlDict = yaml.dictionary {
            if let headersYaml = yamlDict["headers"]?.dictionary {
                traitDefinition.headers = try parseHeaders(headersYaml)
            }
        } else if let yamlString = yaml.string {
            let yamlFromInclude = try parseTraitFromIncludeString(yamlString)
            return try parseTraitDefinition(name: name,
                                            yaml: yamlFromInclude)
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

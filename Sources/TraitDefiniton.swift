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
            guard let keyString = key.string else { throw RAMLError.ramlParsingError(message: "trait key must be a string") }
            let traitDefinition = try parseTraitDefinition(name: keyString, yaml: value)
            traitDefinitions.append(traitDefinition)
        }
        
        return traitDefinitions
    }
    
    private func parseTraitDefinition(name: String, yaml: Yaml) throws -> TraitDefinition {
        let traitDefinition = TraitDefinition(name: name)
        
        if let headersYaml = yaml["headers"].dictionary {
            traitDefinition.headers = try parseHeaders(headersYaml)
        }
        
        return traitDefinition
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
    
}

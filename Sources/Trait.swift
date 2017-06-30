//
//  Trait.swift
//  RAML
//
//  Created by Christoph Pageler on 30.06.17.
//

import Foundation
import Yaml

public class Trait: HasResourceHeaders {
    
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
    
    internal func parseTraits(_ yaml: [Yaml: Yaml]) throws -> [Trait] {
        var traits: [Trait] = []
        
        for (key, value) in yaml {
            guard let keyString = key.string else { throw RAMLError.ramlParsingError(message: "trait key must be a string") }
            let trait = try parseTrait(name: keyString, yaml: value)
            traits.append(trait)
        }
        
        return traits
    }
    
    private func parseTrait(name: String, yaml: Yaml) throws -> Trait {
        let trait = Trait(name: name)
        
        if let headersYaml = yaml["headers"].dictionary {
            trait.headers = try parseHeaders(headersYaml)
        }
        
        return trait
    }
    
}

public protocol HasTraits {
    var traits: [Trait]? { get set }
}

public extension HasTraits {
    
    public func traitWith(name: String) -> Trait? {
        for trait in traits ?? [] {
            if trait.name == name {
                return trait
            }
        }
        return nil
    }
    
}

//
//  TraitUsage.swift
//  RAML
//
//  Created by Christoph Pageler on 02.07.17.
//

import Foundation
import Yaml

public class TraitUsage {
    
    public var name: String
    public var parameters: [String: Yaml]?
    
    public init(name: String) {
        self.name = name
    }
    
    public func parameterFor(key: String) -> Yaml? {
        return parameters?[key]
    }
    
    public func hasParameterFor(key: String) -> Bool {
        return parameterFor(key: key) != nil
    }
}


// MARK: Trait Usage Parsing
internal extension RAML {
    
    internal func parseTraitUsages(yamlArray: [Yaml]) throws -> [TraitUsage] {
        var traitUsages: [TraitUsage] = []
        for traitYaml in yamlArray {
            let traitUsage = try parseTraitUsage(traitYaml)
            traitUsages.append(traitUsage)
        }
        return traitUsages
    }
    
    private func parseTraitUsage(_ yaml: Yaml) throws -> TraitUsage {
        if let traitString = yaml.string {
            return TraitUsage(name: traitString)
        } else if let traitDictionary = yaml.dictionary {
            guard
                let traitName = traitDictionary.keys.first?.string,
                let traitValue = traitDictionary.values.first?.dictionary
            else {
                throw RAMLError.ramlParsingError(.failedParsingTraitUsage)
            }
            let traitUsage = TraitUsage(name: traitName)
            
            var parameters: [String: Yaml] = [:]
            for (key, value) in traitValue {
                guard let keyString = key.string else {
                    throw RAMLError.ramlParsingError(.invalidDataType(for: "Parameter in Trait Usage",
                                                                      mustBeKindOf: "String"))
                }
                parameters[keyString] = value
            }
            traitUsage.parameters = parameters
            
            return traitUsage
        }
        
        throw RAMLError.ramlParsingError(.failedParsingTraitUsage)
    }
    
}


public protocol HasTraitUsages {
    
    var traitUsages: [TraitUsage]? { get set }
    
}


public extension HasTraitUsages {
    
    public func traitUsageWith(name: String) -> TraitUsage? {
        for traitUsage in traitUsages ?? [] {
            if traitUsage.name == name {
                return traitUsage
            }
        }
        return nil
    }
    
    public func hasTraitUsageWith(name: String) -> Bool {
        return traitUsageWith(name: name) != nil
    }
    
}

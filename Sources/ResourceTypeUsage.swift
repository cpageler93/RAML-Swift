//
//  ResourceTypeUsage.swift
//  RAML
//
//  Created by Christoph Pageler on 20.07.17.
//

import Foundation
import Yaml

public class ResourceTypeUsage {
    
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


// MARK: Parsing Resource Type Usage
internal extension RAML {
    
    internal func parseResourceTypeUsages(_ input: ParseInput) throws -> [ResourceTypeUsage]? {
        guard let yaml = input.yaml else { return nil }
        
        switch yaml {
        case .string(let yamlString):
            return [ResourceTypeUsage(name: yamlString)]
        case .dictionary(let yamlDict):
            return try parseResourceTypeUsages(dict: yamlDict)
        default:
            return nil
        }
        
    }
    
    internal func parseResourceTypeUsages(dict: [Yaml: Yaml]) throws -> [ResourceTypeUsage] {
        var resourceTypeUsages: [ResourceTypeUsage] = []
        for (key, value) in dict {
            guard let keyString = key.string else {
                throw RAMLError.ramlParsingError(.invalidDataType(for: "Resource Type Usage Key",
                                                                  mustBeKindOf: "String"))
            }
            let resourceTypeUsage = ResourceTypeUsage(name: keyString)
            
            var parameters: [String: Yaml] = [:]
            for (parameterKey, parameterValue) in value.dictionary ?? [:] {
                guard let parameterKeyString = parameterKey.string else {
                    throw RAMLError.ramlParsingError(.invalidDataType(for: "Parameter in Resource Type Usage",
                                                                      mustBeKindOf: "String"))
                }
                parameters[parameterKeyString] = parameterValue
            }
            resourceTypeUsage.parameters = parameters
            
            resourceTypeUsages.append(resourceTypeUsage)
        }
        return resourceTypeUsages
    }
    
}


public protocol HasResourceTypeUsages {
    
    var types: [ResourceTypeUsage]? { get set }
    
}


public extension HasResourceTypeUsages {
    
    public func resourceTypeUsageWith(name: String) -> ResourceTypeUsage? {
        for resourceTypeUsage in types ?? [] {
            if resourceTypeUsage.name == name {
                return resourceTypeUsage
            }
        }
        return nil
    }
    
    public func hasResourceTypeUsageWith(name: String) -> Bool {
        return resourceTypeUsageWith(name: name) != nil
    }
    
}

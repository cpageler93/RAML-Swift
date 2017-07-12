//
//  ResourceType.swift
//  RAML
//
//  Created by Christoph on 12.07.17.
//

import Foundation
import Yaml

public class ResourceType: HasResourceMethods {
    
    public var identifier: String
    public var usage: String?
    public var description: String?
    public var methods: [ResourceMethod]?
    
    public init(identifier: String) {
        self.identifier = identifier
    }
    
}


// MARK: Parsing Resource Types
internal extension RAML {
    
    internal func parseResourceTypes(yaml: Yaml?) throws -> [ResourceType]? {
        guard let yaml = yaml else { return nil }
        
        switch yaml {
        case .dictionary(let yamlDict):
            return try parseResourceTypes(dict: yamlDict)
        case .string(let yamlString):
            let yaml = try parseResourceTypesFromIncludeString(yamlString)
            guard let resourceTypesDict = yaml.dictionary else {
                throw RAMLError.ramlParsingError(.invalidInclude)
            }
            return try parseResourceTypes(dict: resourceTypesDict)
        default:
            return nil
        }
        
    }
    
    internal func parseResourceTypes(dict: [Yaml: Yaml]) throws -> [ResourceType] {
        var resourceTypes: [ResourceType] = []
        for (key, value) in dict {
            guard let keyString = key.string else {
                throw RAMLError.ramlParsingError(.invalidDataType(for: "ResourceType Key",
                                                                  mustBeKindOf: "String"))
            }
            let resourceType = try parseResourceType(identifier: keyString, yaml: value)
            resourceTypes.append(resourceType)
        }
        return resourceTypes
    }
    
    private func parseResourceType(identifier: String, yaml: Yaml) throws -> ResourceType {
        let resourceType = ResourceType(identifier: identifier)
        
        
        switch yaml {
        case .dictionary(let yamlDict):
            resourceType.usage = yamlDict["usage"]?.string
            resourceType.description = yamlDict["description"]?.string
            resourceType.methods = try parseResourceMethods(yaml: yaml)
        case .string(let yamlString):
            let yamlFromInclude = try parseResourceTypesFromIncludeString(yamlString)
            return try parseResourceType(identifier: identifier,
                                         yaml: yamlFromInclude)
        default:
            throw RAMLError.ramlParsingError(.failedParsingResourceType)
        }
        
        return resourceType
    }
    
    internal func parseResourceTypesFromIncludeString(_ includeString: String) throws -> Yaml {
        try testInclude(includeString)
        return try parseYamlFromIncludeString(includeString,
                                              parentFilePath: try directoryOfInitialFilePath(),
                                              permittedFragmentIdentifier: "ResourceType")
    }
    
}


public protocol HasResourceTypes {
    
    var resourceTypes: [ResourceType]? { get set }
    
}

public extension HasResourceTypes {
    
    public func resourceTypeWith(identifier: String) -> ResourceType? {
        for resourceType in resourceTypes ?? [] {
            if resourceType.identifier == identifier {
                return resourceType
            }
        }
        return nil
    }
    
    public func hasResourceTypeWith(identifier: String) -> Bool {
        return resourceTypeWith(identifier: identifier) != nil
    }
    
}

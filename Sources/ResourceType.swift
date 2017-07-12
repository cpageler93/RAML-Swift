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
    
    internal func parseResourceTypes(_ yaml: [Yaml: Yaml]) throws -> [ResourceType] {
        var resourceTypes: [ResourceType] = []
        for (key, value) in yaml {
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
        
        if let yamlDict = yaml.dictionary {
            
            resourceType.usage = yamlDict["usage"]?.string
            resourceType.description = yamlDict["description"]?.string
            resourceType.methods = try parseResourceMethods(yaml)
            
        } else if let yamlString = yaml.string {
            let yamlFromInclude = try parseResourceTypesFromIncludeString(yamlString)
            return try parseResourceType(identifier: identifier,
                                         yaml: yamlFromInclude)
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

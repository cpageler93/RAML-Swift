//
//  ResourceType.swift
//  RAML
//
//  Created by Christoph on 12.07.17.
//

import Foundation
import Yaml
import PathKit

public class ResourceType: HasResourceMethods, HasLibraries {
    
    public var identifier: String
    public var usage: String?
    public var description: String?
    public var methods: [ResourceMethod]?
    public var uses: [Library]?
    
    public init(identifier: String) {
        self.identifier = identifier
    }
    
}


// MARK: Parsing Resource Types
internal extension RAML {
    
    internal func parseResourceTypes(_ input: ParseInput) throws -> [ResourceType]? {
        guard let yaml = input.yaml else { return nil }
        
        switch yaml {
        case .dictionary(let yamlDict):
            return try parseResourceTypes(dict: yamlDict, parentFilePath: input.parentFilePath)
        case .string(let yamlString):
            let (yaml, path) = try parseResourceTypesFromIncludeString(yamlString, parentFilePath: input.parentFilePath)
            guard let resourceTypesDict = yaml.dictionary else {
                throw RAMLError.ramlParsingError(.invalidInclude)
            }
            return try parseResourceTypes(dict: resourceTypesDict, parentFilePath: path)
        default:
            return nil
        }
        
    }
    
    private func parseResourceTypes(dict: [Yaml: Yaml], parentFilePath: Path?) throws -> [ResourceType] {
        var resourceTypes: [ResourceType] = []
        for (key, value) in dict {
            guard let keyString = key.string else {
                throw RAMLError.ramlParsingError(.invalidDataType(for: "ResourceType Key",
                                                                  mustBeKindOf: "String"))
            }
            let resourceType = try parseResourceType(identifier: keyString,
                                                     yaml: value,
                                                     parentFilePath: parentFilePath)
            resourceTypes.append(resourceType)
        }
        return resourceTypes
    }
    
    private func parseResourceType(identifier: String, yaml: Yaml, parentFilePath: Path?) throws -> ResourceType {
        let resourceType = ResourceType(identifier: identifier)
        
        switch yaml {
        case .dictionary(let yamlDict):
            resourceType.usage = yamlDict["usage"]?.string
            resourceType.description = yamlDict["description"]?.string
            resourceType.methods = try parseResourceMethods(ParseInput(yaml, parentFilePath))
            resourceType.uses = try parseLibraries(ParseInput(yaml["uses"], parentFilePath))
        case .string(let yamlString):
            let (yamlFromInclude, path) = try parseResourceTypesFromIncludeString(yamlString, parentFilePath: parentFilePath)
            return try parseResourceType(identifier: identifier,
                                         yaml: yamlFromInclude,
                                         parentFilePath: path)
        default:
            throw RAMLError.ramlParsingError(.failedParsingResourceType)
        }
        
        return resourceType
    }
    
    private func parseResourceTypesFromIncludeString(_ includeString: String, parentFilePath: Path?) throws -> (Yaml, Path) {
        return try parseYamlFromIncludeString(includeString, parentFilePath: parentFilePath, permittedFragmentIdentifier: "ResourceType")
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

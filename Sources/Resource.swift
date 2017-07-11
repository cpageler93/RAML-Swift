//
//  Resource.swift
//  RAML
//
//  Created by Christoph on 30.06.17.
//

import Foundation
import Yaml

public class Resource: HasResources, HasResourceMethods {
    
    public var path: String
    public var displayName: String?
    public var description: String?
    public var annotations: [Annotation]?
    public var methods: [ResourceMethod]?
    // traits
    // type
    // securedBy
    // uriParameters
    public var resources: [Resource]?
    
    public init(path: String) {
        self.path = path
    }
}


// MARK: Resources Parsing
internal extension RAML {
    
    internal func parseResources(_ yaml: Yaml) throws -> [Resource]? {
        var resources: [Resource] = []
        for (key, value) in yaml.dictionary ?? [:] {
            if let keyString = key.string, keyString.hasPrefix("/") {
                let resource = try parseResource(path: keyString, yaml: value)
                resources.append(resource)
            }
        }
        
        if resources.count > 0 {
            return resources
        } else {
            return nil
        }
    }
    
    internal func parseResource(path: String, yaml: Yaml) throws -> Resource {
        let resource = Resource(path: path)
        resource.methods = try parseResourceMethods(yaml)
        resource.resources = try parseResources(yaml)
        return resource
    }
    
}


public protocol HasResources {
    
    var resources: [Resource]? { get set }
    
}


extension HasResources {
    
    public func resourceWith(path: String) -> Resource? {
        for resource in resources ?? [] {
            if resource.path == path {
                return resource
            }
        }
        return nil
    }
    
    public func hasResourceWith(path: String) -> Bool {
        return resourceWith(path: path) != nil
    }
    
}

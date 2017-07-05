//
//  Resource.swift
//  RAML
//
//  Created by Christoph on 30.06.17.
//

import Foundation
import Yaml

public class Resource: HasResources, HasResourceMethods, ResourceParent {
    
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
    public var parent: ResourceParent
    
    public init(path: String, parent: ResourceParent) {
        self.path = path
        self.parent = parent
    }
    
    public func absolutePath() -> String {
        return parent.absolutePath() + path
    }
}

// Resources Parsing
extension RAML {
    
    internal func parseResources(_ yaml: Yaml, parent: ResourceParent) throws -> [Resource]? {
        var resources: [Resource] = []
        for (key, value) in yaml.dictionary ?? [:] {
            if let keyString = key.string, keyString.hasPrefix("/") {
                let resource = try parseResource(path: keyString,
                                                 yaml: value,
                                                 parent: parent)
                resources.append(resource)
            }
        }
        
        if resources.count > 0 {
            return resources
        } else {
            return nil
        }
    }
    
    internal func parseResource(path: String, yaml: Yaml, parent: ResourceParent) throws -> Resource {
        let resource = Resource(path: path, parent: self)
        resource.parent = parent
        resource.methods = try parseResourceMethods(yaml)
        resource.resources = try parseResources(yaml, parent: resource)
        
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

public protocol ResourceParent: HasAbsolutePath {
    
}

public protocol HasAbsolutePath {
    func absolutePath() -> String
}

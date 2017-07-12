//
//  ResourceMethod.swift
//  RAML
//
//  Created by Christoph on 30.06.17.
//

import Foundation
import Yaml

public enum ResourceMethodType: String {
    
    case get
    case patch
    case put
    case post
    case delete
    case options
    case head
    
}


public class ResourceMethod: HasHeaders, HasAnnotations, HasTraitUsages, HasMethodResponses, HasSecuritySchemeUsages {
    
    public var type: ResourceMethodType
    public var displayName: String?
    public var description: String?
    public var annotations: [Annotation]?
    // queryParameters
    public var headers: [Header]?
    // queryString
    public var responses: [MethodResponse]?
    public var body: ResponseBody?
    // protocols
    public var traitUsages: [TraitUsage]?
    public var securedBy: [SecuritySchemeUsage]?
    
    public init(type: ResourceMethodType) {
        self.type = type
    }
    
}


// MARK: ResourceMethod Parsing
internal extension RAML {
    
    internal func parseResourceMethods(yaml: Yaml?) throws -> [ResourceMethod]? {
        guard let yaml = yaml else { return nil }
        
        var resourceMethods: [ResourceMethod] = []
        
        let availableMethods = [
            "get",
            "patch",
            "put",
            "post",
            "delete",
            "options",
            "head"
        ]
        
        for (key, value) in yaml.dictionary ?? [:] {
            if let keyString = key.string,
                   availableMethods.contains(keyString),
               let resourceMethod = try parseResourceMethod(keyString, fromYaml: value) {
                resourceMethods.append(resourceMethod)
            }
        }
        
        if resourceMethods.count > 0 {
            return resourceMethods
        } else {
            return nil
        }
    }
    
    private func parseResourceMethod(_ method: String, fromYaml yaml: Yaml) throws -> ResourceMethod? {
        guard let methodType = ResourceMethodType(rawValue: method) else { return nil }
        let resourceMethod = ResourceMethod(type: methodType)
        
        resourceMethod.headers = try parseHeaders(yaml: yaml["headers"])
        resourceMethod.description = yaml["description"].string
        resourceMethod.responses = try parseResponses(yaml: yaml["responses"])
        resourceMethod.traitUsages = try parseTraitUsages(yaml: yaml["is"])
        resourceMethod.body = try parseResponseBody(yaml: yaml["body"])
        resourceMethod.securedBy = try parseSecuritySchemeUsages(yaml: yaml["securedBy"])
        
        return resourceMethod
    }
    
}


public protocol HasResourceMethods {
    
    var methods: [ResourceMethod]? { get set }
    
}


public extension HasResourceMethods {
    
    public func methodWith(type: ResourceMethodType) -> ResourceMethod? {
        for method in methods ?? [] {
            if method.type == type {
                return method
            }
        }
        return nil
    }
    
    public func hasMethodWith(type: ResourceMethodType) -> Bool {
        return methodWith(type: type) != nil
    }
    
}

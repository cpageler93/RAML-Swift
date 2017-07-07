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

public class ResourceMethod: HasResourceHeaders, HasAnnotations, HasTraitUsages, HasMethodResponses {
    
    public var type: ResourceMethodType
    public var displayName: String?
    public var description: String?
    public var annotations: [Annotation]?
    // queryParameters
    public var headers: [ResourceHeader]?
    // queryString
    public var responses: [MethodResponse]?
    public var body: ResponseBody?
    // protocols
    public var traitUsages: [TraitUsage]?
    // securedBy
    
    public init(type: ResourceMethodType) {
        self.type = type
    }
}

// MARK: ResourceMethod Parsing
extension RAML {
    
    internal func parseResourceMethods(_ yaml: Yaml) throws -> [ResourceMethod]? {
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
        
        if let headersYaml = yaml["headers"].dictionary {
            resourceMethod.headers = try parseHeaders(headersYaml)
        }
        
        if let descriptionString = yaml["description"].string {
            resourceMethod.description = descriptionString
        }
        
        if let responsesYaml = yaml["responses"].dictionary {
            resourceMethod.responses = try parseResponses(responsesYaml)
        }
        
        if let singleTraitString = yaml["is"].string {
            resourceMethod.traitUsages = [TraitUsage(name: singleTraitString)]
        } else if let traitsYamlArray = yaml["is"].array {
            resourceMethod.traitUsages = try parseTraitUsages(yamlArray: traitsYamlArray)
        }
        
        resourceMethod.body = try parseResponseBody(yaml["body"])
        
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

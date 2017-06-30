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

public class ResourceMethod {
    
    public var type: ResourceMethodType
    public var displayName: String?
    public var description: String?
    public var annotations: [Annotation]?
    // queryParameters
    // headers
    // queryString
    // responses
    // body
    // protocols
    // is (traits)
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
               let resourceMethod = parseResourceMethod(keyString, fromYaml: value) {
                resourceMethods.append(resourceMethod)
            }
        }
        
        if resourceMethods.count > 0 {
            return resourceMethods
        } else {
            return nil
        }
    }
    
    private func parseResourceMethod(_ method: String, fromYaml yaml: Yaml) -> ResourceMethod? {
        guard let methodType = ResourceMethodType(rawValue: method) else { return nil }
        var resourceMethod = ResourceMethod(type: methodType)
        return resourceMethod
    }
    
}

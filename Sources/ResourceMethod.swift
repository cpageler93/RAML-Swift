//
//  ResourceMethod.swift
//  RAML
//
//  Created by Christoph on 30.06.17.
//

import Foundation
import Yaml
import PathKit

public enum ResourceMethodType: String {
    
    case get
    case patch
    case put
    case post
    case delete
    case options
    case head
    
}


public class ResourceMethod: HasHeaders, HasAnnotations, HasTraitUsages, HasMethodResponses, HasSecuritySchemeUsages, HasQueryParameters {
    
    public var type: ResourceMethodType
    public var displayName: String?
    public var description: String?
    public var annotations: [Annotation]?
    public var queryParameters: [URIParameter]?
    public var headers: [Header]?
    public var queryString: QueryString?
    public var responses: [MethodResponse]?
    public var body: Body?
    public var protocols: Protocols?
    public var traitUsages: [TraitUsage]?
    public var securedBy: [SecuritySchemeUsage]?
    
    public init(type: ResourceMethodType) {
        self.type = type
    }
    
    internal init() {
        self.type = .get
    }
    
}


// MARK: ResourceMethod Parsing
internal extension RAML {
    
    internal func parseResourceMethods(_ input: ParseInput) throws -> [ResourceMethod]? {
        guard let yaml = input.yaml else { return nil }
        
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
                let resourceMethod = try parseResourceMethod(keyString, fromYaml: value, parentFilePath: input.parentFilePath) {
                resourceMethods.append(resourceMethod)
            }
        }
        
        if resourceMethods.count > 0 {
            return resourceMethods
        } else {
            return nil
        }
    }
    
    private func parseResourceMethod(_ method: String, fromYaml yaml: Yaml, parentFilePath: Path?) throws -> ResourceMethod? {
        guard let methodType = ResourceMethodType(rawValue: method) else { return nil }
        let resourceMethod = ResourceMethod(type: methodType)
        
        resourceMethod.displayName      = yaml["displayName"].string
        resourceMethod.description      = yaml["description"].string
        resourceMethod.annotations      = try parseAnnotations(ParseInput(yaml, parentFilePath))
        resourceMethod.queryParameters  = try parseURIParameters(ParseInput(yaml["queryParameters"], parentFilePath))
        resourceMethod.headers          = try parseHeaders(ParseInput(yaml["headers"], parentFilePath))
        resourceMethod.queryString      = try parseQueryString(ParseInput(yaml["queryString"], parentFilePath))
        resourceMethod.responses        = try parseResponses(ParseInput(yaml["responses"], parentFilePath))
        resourceMethod.body             = try parseBody(ParseInput(yaml["body"], parentFilePath))
        resourceMethod.protocols        = try parseProtocols(ParseInput(yaml["protocols"], parentFilePath))
        resourceMethod.traitUsages      = try parseTraitUsages(ParseInput(yaml["is"], parentFilePath))
        resourceMethod.securedBy        = try parseSecuritySchemeUsages(ParseInput(yaml["securedBy"], parentFilePath))
        
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


// MARK: Default Values
public extension ResourceMethod {
    
    public convenience init(initWithDefaultsBasedOn resourceMethod: ResourceMethod, raml: RAML) {
        self.init()
        
        self.type               = resourceMethod.type
        self.displayName        = resourceMethod.displayName
        self.description        = resourceMethod.description
        self.annotations        = resourceMethod.annotations?.map { $0.applyDefaults() }
        self.queryParameters    = resourceMethod.queryParameters?.map { $0.applyDefaults() }
        self.headers            = resourceMethod.headers?.map { $0.applyDefaults() }
        self.queryString        = resourceMethod.queryString?.applyDefaults()
        self.responses          = resourceMethod.responses?.map { $0.applyDefaults(raml: raml) }
        self.body               = resourceMethod.body?.applyDefaults(raml: raml)
        self.protocols          = resourceMethod.protocols ?? Protocols.defaultProtocols()
        self.traitUsages        = resourceMethod.traitUsages?.map { $0.applyDefaults() }
        self.securedBy          = resourceMethod.securedBy?.map { $0.applyDefaults() }
    }
    
    public func applyDefaults(raml: RAML) -> ResourceMethod {
        return ResourceMethod(initWithDefaultsBasedOn: self, raml: raml)
    }
    
}


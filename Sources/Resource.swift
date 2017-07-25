//
//  Resource.swift
//  RAML
//
//  Created by Christoph on 30.06.17.
//

import Foundation
import Yaml
import PathKit

public class Resource: HasAnnotations, HasResources, HasResourceMethods, HasSecuritySchemeUsages, HasURIParameters, HasTraitUsages, HasResourceTypeUsages {
    
    public var path: String
    public var displayName: String?
    public var description: String?
    public var annotations: [Annotation]?
    public var methods: [ResourceMethod]?
    public var traitUsages: [TraitUsage]?
    public var types: [ResourceTypeUsage]?
    public var securedBy: [SecuritySchemeUsage]?
    public var uriParameters: [URIParameter]?
    public var resources: [Resource]?
    
    public init(path: String) {
        self.path = path
    }
    
    internal init() {
        self.path = ""
    }
}


// MARK: Resources Parsing
internal extension RAML {
    
    internal func parseResources(_ input: ParseInput) throws -> [Resource]? {
        guard let yaml = input.yaml else { return nil }
        
        var resources: [Resource] = []
        for (key, value) in yaml.dictionary ?? [:] {
            if let keyString = key.string, keyString.hasPrefix("/") {
                let resource = try parseResource(path: keyString, yaml: value, parentFilePath: input.parentFilePath)
                resources.append(resource)
            }
        }
        
        if resources.count > 0 {
            return resources
        } else {
            return nil
        }
    }
    
    private func parseResource(path: String, yaml: Yaml, parentFilePath: Path?) throws -> Resource {
        let resource = Resource(path: path)
        
        resource.displayName    = yaml["displayName"].string
        resource.description    = yaml["displayName"].string
        resource.annotations    = try parseAnnotations(ParseInput(yaml, parentFilePath))
        resource.methods        = try parseResourceMethods(ParseInput(yaml, parentFilePath))
        resource.types          = try parseResourceTypeUsages(ParseInput(yaml["type"], parentFilePath))
        resource.securedBy      = try parseSecuritySchemeUsages(ParseInput(yaml["securedBy"], parentFilePath))
        resource.traitUsages    = try parseTraitUsages(ParseInput(yaml["is"], parentFilePath))
        resource.uriParameters  = try parseURIParameters(ParseInput(yaml["uriParameters"], parentFilePath))
        resource.resources      = try parseResources(ParseInput(yaml, parentFilePath))
        
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


// MARK: Default Values
public extension Resource {
    
    internal func methodsOrDefault(raml: RAML) -> [ResourceMethod]? {
        if let methods = methods { return methods.map { $0.applyDefaults(raml: raml) } }
        
        let defaultMethod = ResourceMethod(type: .get)
        
        defaultMethod.displayName = displayName
        defaultMethod.description = description
        defaultMethod.annotations = annotations
        defaultMethod.traitUsages = traitUsages
        defaultMethod.securedBy = securedBy
        
        return [defaultMethod.applyDefaults(raml: raml)]
    }
    
    public convenience init(initWithDefaultsBasedOn resource: Resource, raml: RAML) {
        self.init()
        
        self.path           = resource.path
        self.displayName    = resource.displayName
        self.description    = resource.description
        self.annotations    = resource.annotations?.map { $0.applyDefaults() }
        self.methods        = resource.methodsOrDefault(raml: raml)
        self.traitUsages    = resource.traitUsages?.map { $0.applyDefaults() }
        self.types          = resource.types?.map { $0.applyDefaults() }
        self.securedBy      = resource.securedBy?.map { $0.applyDefaults() }
        self.uriParameters  = resource.uriParameters?.map { $0.applyDefaults() }
        self.resources      = resource.resources?.map { $0.applyDefaults(raml: raml) }
    }
    
    public func applyDefaults(raml: RAML) -> Resource {
        return Resource(initWithDefaultsBasedOn: self, raml: raml)
    }
    
}

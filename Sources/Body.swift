//
//  Body.swift
//  RAML
//
//  Created by Christoph on 06.07.17.
//

import Foundation
import Yaml

public class Body: HasBodyMediaTypes, HasAnnotations {
    
    public var type: DataType?
    public var properties: [Property]?
    public var examples: [Example]?
    public var mediaTypes: [BodyMediaType]?
    public var annotations: [Annotation]?
    
}


// MARK: Body Parsing
internal extension RAML {
    
    internal func parseBody(_ input: ParseInput) throws -> Body? {
        guard let yaml = input.yaml else { return nil }
        
        switch yaml {
        case .string(let yamlString):
            let body = Body()
            body.type = DataType.dataTypeEnumFrom(string: yamlString)
            return body
        case .dictionary:
            let body = Body()
            body.type           = try DataType.dataTypeEnumFrom(yaml: yaml, dictKey: "type")
            body.properties     = try parseProperties(yaml: yaml)
            body.examples       = try parseExampleOrExamples(yamlDict: yaml.dictionary)
            body.mediaTypes     = try parseBodyMediaTypes(input)
            body.annotations    = try parseAnnotations(input)
            return body
        default:
            return nil
        }
        
    }
}


// MARK: Default Values
public extension Body {
    
    public func mediaTypesOrDefault(raml: RAML) -> [BodyMediaType]? {
        if let mediaTypes = mediaTypes { return mediaTypes.map { $0.applyDefaultsForBodyMediaType() } }
        
        // inherit media types from raml base
        var bodyMediaTypes: [BodyMediaType] = []
        for mediaType in raml.mediaTypesOrDefault() {
            let bodyMediaType = BodyMediaType(identifier: mediaType.identifier)
            
            bodyMediaType.type          = type
            bodyMediaType.properties    = properties
            bodyMediaType.examples      = examples
            
            bodyMediaTypes.append(bodyMediaType.applyDefaultsForBodyMediaType())
        }
        
        return bodyMediaTypes
    }
    
    public func typeOrDefault() -> DataType? {
        if let type = type { return type }
        
        if properties == nil {
            return DataType.any
        }
        
        return nil
    }
    
    public convenience init(initWithDefaultsBasedOn body: Body, raml: RAML) {
        self.init()
        
        self.type           = body.typeOrDefault()
        self.properties     = body.properties?.map { $0.applyDefaults() }
        self.examples       = body.examples?.map { $0.applyDefaults() }
        self.mediaTypes     = body.mediaTypesOrDefault(raml: raml)
        self.annotations    = body.annotations?.map { $0.applyDefaults() }
    }
    
    public func applyDefaults(raml: RAML) -> Body {
        return Body(initWithDefaultsBasedOn: self, raml: raml)
    }
    
}


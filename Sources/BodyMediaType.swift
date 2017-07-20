//
//  BodyMediaType.swift
//  RAML
//
//  Created by Christoph on 07.07.17.
//

import Foundation
import Yaml

public class BodyMediaType: MediaType, HasProperties, HasExamples {
    
    public var type: DataType?
    public var properties: [Property]?
    public var examples: [Example]?
    
}


// MARK: BodyMediaType Parsing
public extension RAML {
    
    internal func parseBodyMediaTypes(_ input: ParseInput) throws -> [BodyMediaType]? {
        guard let yaml = input.yaml else { return nil }
        
        switch yaml {
        case .dictionary(let yamlDict):
            return try parseBodyMediaTypes(dict: yamlDict)
        default:
            return nil
        }
        
    }
    
    internal func parseBodyMediaTypes(dict: [Yaml: Yaml]) throws -> [BodyMediaType]? {
        var bodyMediaTypes: [BodyMediaType] = []
        for (key, value) in dict {
            guard let keyString = key.string else {
                throw RAMLError.ramlParsingError(.invalidDataType(for: "MediaType in Response Body",
                                                                  mustBeKindOf: "String"))
            }
            guard BodyMediaType.isMediaType(string: keyString) else {
                continue
            }
            let mediaType = try parseBodyMediaType(identifier: keyString, yaml: value)
            bodyMediaTypes.append(mediaType)
        }
        
        if bodyMediaTypes.count > 0 {
            return bodyMediaTypes
        } else {
            return nil
        }
    }
    
    private func parseBodyMediaType(identifier: String, yaml: Yaml) throws -> BodyMediaType {
        let bodyMediaType = BodyMediaType(identifier: identifier)
        
        bodyMediaType.type          = try DataType.dataTypeEnumFrom(yaml: yaml, dictKey: "type")
        bodyMediaType.properties    = try parseProperties(yaml: yaml)
        bodyMediaType.examples      = try parseExampleOrExamples(yamlDict: yaml.dictionary)
        
        return bodyMediaType
    }
    
}


public protocol HasBodyMediaTypes {
    
    var mediaTypes: [BodyMediaType]? { get set }
    
}


public extension HasBodyMediaTypes {
    
    public func mediaTypeWith(identifier: String) -> BodyMediaType? {
        for mediaType in mediaTypes ?? [] {
            if mediaType.identifier == identifier {
                return mediaType
            }
        }
        return nil
    }
    
    public func hasMediaTypeWith(identifier: String) -> Bool {
        return mediaTypeWith(identifier: identifier) != nil
    }
    
}

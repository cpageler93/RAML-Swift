//
//  BodyMediaType.swift
//  RAML
//
//  Created by Christoph on 07.07.17.
//

import Foundation
import Yaml

public class BodyMediaType: MediaType {
    
    public var type: DataType?
    
}


// MARK: BodyMediaType Parsing
public extension RAML {
    
    internal func parseBodyMediaTypes(yaml: Yaml?) throws -> [BodyMediaType]? {
        guard let yaml = yaml else { return nil }
        
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
        bodyMediaType.type = try DataType.dataTypeEnumFrom(yaml: yaml, dictKey: "type")
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

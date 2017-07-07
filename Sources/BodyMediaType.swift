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
    
    internal func parseBodyMediaTypes(_ yaml: [Yaml: Yaml]) throws -> [BodyMediaType]? {
        var bodyMediaTypes: [BodyMediaType] = []
        for (key, value) in yaml {
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
        
        if let typeString = yaml["type"].string {
            bodyMediaType.type = DataType.dataTypeEnumFrom(string: typeString)
        }
        
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
    
}

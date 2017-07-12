//
//  RAML+MediaType.swift
//  RAML
//
//  Created by Christoph Pageler on 24.06.17.
//

import Foundation
import Yaml

public class MediaType {
    
    public var identifier: String
    
    public init(identifier: String) {
        self.identifier = identifier
    }
    
}


// MARK: MediaType Parsing
internal extension RAML {
    
    internal func parseMediaTypes(yaml: Yaml?) throws -> [MediaType]? {
        guard let yaml = yaml else { return nil }
        
        switch yaml {
        case .array(let yamlArray):
            return try parseMediaTypes(array: yamlArray)
        case .string(let yamlString):
            return [parseMediaType(string:yamlString)]
        default:
            return nil
        }
        // TODO: Consider Includes
    }
    
    internal func parseMediaTypes(array: [Yaml]) throws -> [MediaType] {
        var mediaTypes: [MediaType] = []
        for yamlMediaType in array {
            guard let mediaTypeString = yamlMediaType.string else {
                throw RAMLError.ramlParsingError(.invalidDataType(for: "MediaType",
                                                                  mustBeKindOf: "String"))
            }
            let mediaType = parseMediaType(string: mediaTypeString)
            mediaTypes.append(mediaType)
        }
        return mediaTypes
    }
    
    internal func parseMediaType(string: String) -> MediaType {
        return MediaType(identifier: string)
    }
    
}


public protocol HasMediaTypes {
    
    var mediaTypes: [MediaType]? { get set }
    
}


public extension HasMediaTypes {
    
    public func mediaTypeWith(identifier: String) -> MediaType? {
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

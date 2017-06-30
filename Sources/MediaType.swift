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
extension RAML {
    
    internal func parseMediaTypes(_ yaml: [Yaml]) throws -> [MediaType] {
        var mediaTypes: [MediaType] = []
        for yamlMediaType in yaml {
            guard let mediaTypeString = yamlMediaType.string else { throw RAMLError.ramlParsingError(message: "MediaType must be a string") }
            let mediaType = parseMediaType(mediaTypeString)
            mediaTypes.append(mediaType)
        }
        return mediaTypes
    }
    
    internal func parseMediaType(_ string: String) -> MediaType {
        return MediaType(identifier: string)
    }
    
    
}

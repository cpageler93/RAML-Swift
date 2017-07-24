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
    
    internal init() {
        self.identifier = ""
    }
    
    public static func isMediaType(string: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: ".*/.*") else { return false }
        let matches = regex.matches(in: string, options: [], range: NSMakeRange(0, string.characters.count))
        return matches.count == 1
    }
    
}


// MARK: MediaType Parsing
internal extension RAML {
    
    internal func parseMediaTypes(_ input: ParseInput) throws -> [MediaType]? {
        guard let yaml = input.yaml else { return nil }
        
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
    
    private func parseMediaTypes(array: [Yaml]) throws -> [MediaType] {
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
    
    private func parseMediaType(string: String) -> MediaType {
        return MediaType(identifier: string)
    }
    
}


public protocol HasXXXTypes { }

public extension HasXXXTypes {
    public func __TypeWith(array: [MediaType]?, identifier: String) -> MediaType? {
        for mediaType in array ?? [] {
            if mediaType.identifier == identifier {
                return mediaType
            }
        }
        return nil
    }
    
    public func has__TypeWith(array: [MediaType]?, identifier: String) -> Bool {
        return __TypeWith(array: array, identifier: identifier) != nil
    }
}


public protocol HasMediaTypes: HasXXXTypes {
    
    var mediaTypes: [MediaType]? { get set }
    
}


public protocol HasFileTypes: HasXXXTypes {
    
    var fileTypes: [MediaType]? { get set }
    
}


public extension HasMediaTypes {
    
    public func mediaTypeWith(identifier: String) -> MediaType? {
        return __TypeWith(array: mediaTypes, identifier: identifier)
    }
    
    public func hasMediaTypeWith(identifier: String) -> Bool {
        return has__TypeWith(array: mediaTypes, identifier: identifier)
    }

}

public extension HasFileTypes {
    
    public func fileTypeWith(identifier: String) -> MediaType? {
        return __TypeWith(array: fileTypes, identifier: identifier)
    }
    
    public func hasFileTypeWith(identifier: String) -> Bool {
        return has__TypeWith(array: fileTypes, identifier: identifier)
    }
    
}

// MARK: Default Values
public extension MediaType {
    
    public convenience init(initWithDefaultsBasedOn mediaType: MediaType) {
        self.init()
        self.identifier = mediaType.identifier
    }
    
    public func applyDefaults() -> MediaType {
        return MediaType(initWithDefaultsBasedOn: self)
    }
    
    public static func defaultMediaTypes() -> [MediaType] {
        return [MediaType(identifier: "application/json")]
    }
    
}

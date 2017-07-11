//
//  File.swift
//  RAML
//
//  Created by Christoph Pageler on 30.06.17.
//

import Foundation
import Yaml

public enum HeaderType: String {
    
    case string
    case array
    
}


public class Header {
    
    public class Items {
        public var pattern: String?
        public var example: String?
    }
    
    public var key: String
    public var description: String?
    public var type: HeaderType?
    public var pattern: String?
    public var example: String?
    public var items: Items?
    public var required: Bool?
    
    public init(key: String) {
        self.key = key
    }
    
}


// MARK: Parsing Headers
internal extension RAML {
    
    internal func parseHeaders(_ yaml: [Yaml: Yaml]) throws -> [Header] {
        var headers: [Header] = []
        for (key, value) in yaml {
            guard let keyString = key.string else {
                throw RAMLError.ramlParsingError(.invalidDataType(for: "Header Key",
                                                                  mustBeKindOf: "Sring"))
            }
            let header = try parseHeader(key: keyString, yaml: value)
            headers.append(header)
        }
        return headers
    }
    
    private func parseHeader(key: String, yaml: Yaml) throws -> Header {
        let header = Header(key: key)
        
        header.description = yaml["description"].string
        header.pattern = yaml["pattern"].string
        header.example = yaml["example"].string
        header.required = yaml["required"].bool
        
        if let typeString = yaml["type"].string {
            guard let resourceHeaderType = HeaderType(rawValue: typeString) else {
                throw RAMLError.ramlParsingError(.invalidHeaderType(typeString))
            }
            header.type = resourceHeaderType
        }
        
        if let itemsYaml = yaml["items"].dictionary {
            header.items = try parseResourceHeaderItems(itemsYaml)
        }
        
        return header
    }
    
    private func parseResourceHeaderItems(_ yaml: [Yaml: Yaml]) throws -> Header.Items {
        let items = Header.Items()
        
        items.pattern = yaml["pattern"]?.string
        items.example = yaml["example"]?.string
        
        return items
    }
    
}


public protocol HasHeaders {
    
    var headers: [Header]? { get set }
    
}


public extension HasHeaders {
    
    public func headerWith(key: String) -> Header? {
        for header in headers ?? [] {
            if header.key == key {
                return header
            }
        }
        return nil
    }
    
    public func hasHeaderWith(key: String) -> Bool {
        return headerWith(key: key) != nil
    }
    
}

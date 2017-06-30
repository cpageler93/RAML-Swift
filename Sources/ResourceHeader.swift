//
//  File.swift
//  RAML
//
//  Created by Christoph Pageler on 30.06.17.
//

import Foundation
import Yaml

public enum ResourceHeaderType: String {
    case string
    case array
}

public class ResourceHeader {
    
    public class Items {
        public var pattern: String?
        public var example: String?
    }
    
    public var key: String
    public var description: String?
    public var type: ResourceHeaderType = .string
    public var example: String?
    public var items: Items?
    public var required: Bool = true
    
    public init(key: String) {
        self.key = key
    }
    
}

// Parsing Headers
extension RAML {
    
    internal func parseHeaders(_ yaml: [Yaml: Yaml]) throws -> [ResourceHeader] {
        var headers: [ResourceHeader] = []
        for (key, value) in yaml {
            guard let keyString = key.string else { throw RAMLError.ramlParsingError(message: "header key must be a string") }
            let header = try parseHeader(key: keyString, yaml: value)
            headers.append(header)
        }
        return headers
    }
    
    private func parseHeader(key: String, yaml: Yaml) throws -> ResourceHeader {
        let header = ResourceHeader(key: key)
        
        if let descriptionString = yaml["description"].string {
            header.description = descriptionString
        }
        
        if let typeString = yaml["type"].string {
            guard let resourceHeaderType = ResourceHeaderType(rawValue: typeString) else {
                throw RAMLError.ramlParsingError(message: "resource header type `\(typeString)` not valid")
            }
            header.type = resourceHeaderType
        }
        
        if let requiredBool = yaml["required"].bool {
            header.required = requiredBool
        }
        
        if let itemsYaml = yaml["items"].dictionary {
            header.items = try parseResourceHeaderItems(itemsYaml)
        }
        
        return header
    }
    
    private func parseResourceHeaderItems(_ yaml: [Yaml: Yaml]) throws -> ResourceHeader.Items {
        let items = ResourceHeader.Items()
        
        if let patternString = yaml["pattern"]?.string {
            items.pattern = patternString
        }
        
        if let exampleString = yaml["example"]?.string {
            items.example = exampleString
        }
        
        return items
    }
}

public protocol HasResourceHeaders {
    var headers: [ResourceHeader]? { get set }
}

public extension HasResourceHeaders {
    
    public func headerWith(key: String) -> ResourceHeader? {
        for header in headers ?? [] {
            if header.key == key {
                return header
            }
        }
        return nil
    }
    
}

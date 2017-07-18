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
    
    public static func fromOptional(_ string: String?) throws -> HeaderType? {
        guard let string = string else { return nil }
        guard let headerType = HeaderType(rawValue: string) else {
            throw RAMLError.ramlParsingError(.invalidHeaderType(string))
        }
        return headerType
    }
    
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
    
    internal func parseHeaders(_ input: ParseInput) throws -> [Header]? {
        guard let yaml = input.yaml else { return nil }
        
        if let headerDict = yaml.dictionary {
            return try parseHeaders(dict: headerDict)
        }
        
        return nil
    }
    
    internal func parseHeaders(dict: [Yaml: Yaml]) throws -> [Header] {
        var headers: [Header] = []
        for (key, value) in dict {
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
        header.type = try HeaderType.fromOptional(yaml["type"].string)
        header.items = try parseResourceHeaderItems(yaml: yaml["items"])
        
        return header
    }
    
    private func parseResourceHeaderItems(yaml: Yaml?) throws -> Header.Items? {
        guard let yaml = yaml else { return nil }
        
        switch yaml {
        case .dictionary(let yamlDict):
            let items = Header.Items()
            
            items.pattern = yamlDict["pattern"]?.string
            items.example = yamlDict["example"]?.string
            
            return items
        default:
            return nil
        }
        
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

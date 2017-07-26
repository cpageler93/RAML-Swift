//
//  RAML+URIParameter.swift
//  RAML
//
//  Created by Christoph Pageler on 24.06.17.
//

import Foundation
import Yaml

public class URIParameter {
    
    public enum ParameterType: String {
        case array
        case integer
        case string
        
        static func fromOptional(_ string: String?) -> ParameterType? {
            guard let string = string else { return nil }
            return ParameterType(rawValue: string)
        }
    }
    
    public class URIParameterItems {
        
        public enum ParameterItemType: String {
            case string
            case integer
        }
        
        public var type: ParameterItemType?
        public var minLength: Int?
        
        // MARK: Default Values
        public convenience init(initWithDefaultsBasedOn items: URIParameterItems) {
            self.init()
            
            self.type = items.type
            self.minLength = items.minLength
        }
        
        public func applyDefaults() -> URIParameterItems {
            return URIParameterItems(initWithDefaultsBasedOn: self)
        }
    }
    
    public var identifier: String
    public var description: String?
    public var type: ParameterType?
    public var items: URIParameterItems?
    public var uniqueItems: Bool?
    public var `enum`: StringEnum?
    public var required: Bool?
    public var example: Int?
    public var minimum: Int?
    public var maximum: Int?
    public var `default`: Int?
    
    public init(identifier: String) {
        self.identifier = identifier
    }
    
    internal init() {
        self.identifier = ""
    }
    
}


// MARK: URIParameters Parsing
internal extension RAML {
    
    internal func parseURIParameters(_ input: ParseInput) throws -> [URIParameter]? {
        guard let yaml = input.yaml else { return nil }
        
        switch yaml {
        case .dictionary(let yamlDict):
            return try parseURIParameters(dict: yamlDict)
        default:
            return nil
        }
        
    }
    
    private func parseURIParameters(dict: [Yaml: Yaml]) throws -> [URIParameter] {
        var uriParameters: [URIParameter] = []
        
        for (key, value) in dict {
            guard let keyString = key.string else {
                throw RAMLError.ramlParsingError(.invalidDataType(for: "URIParameter Key",
                                                                  mustBeKindOf: "String"))
            }
            
            let uriParameter = URIParameter(identifier: keyString)
            
            uriParameter.description    = value["description"].string
            uriParameter.type           = URIParameter.ParameterType.fromOptional(value["type"].string)
            uriParameter.uniqueItems    = value["uniqueItems"].bool
            if let yamlItems = value["items"].dictionary {
                let items = URIParameter.URIParameterItems()
                
                if let itemsTypeString = yamlItems["type"]?.string {
                    items.type = URIParameter.URIParameterItems.ParameterItemType(rawValue: itemsTypeString)
                }
                items.minLength = yamlItems["minLength"]?.int
                
                uriParameter.items = items
            }
            uriParameter.enum = try parseStringEnum(ParseInput(value["enum"]))
            uriParameter.required = value["required"].bool
            uriParameter.example = value["example"].int
            uriParameter.minimum = value["minimum"].int
            uriParameter.maximum = value["maximum"].int
            uriParameter.default = value["default"].int
            
            uriParameters.append(uriParameter)
        }
        
        return uriParameters
    }
    
}

public protocol Has__URIParameters { }


public extension Has__URIParameters {
    
    public func __URIParameterWith(array: [URIParameter]?, identifier: String) -> URIParameter? {
        for baseURIParameter in array ?? [] {
            if baseURIParameter.identifier == identifier {
                return baseURIParameter
            }
        }
        return nil
    }
    
    public func has__URIParameterWith(array: [URIParameter]?, identifier: String) -> Bool {
        return __URIParameterWith(array: array, identifier: identifier) != nil
    }
    
}


public protocol HasURIParameters: Has__URIParameters {
    
    var uriParameters: [URIParameter]? { get set }
    
}


public extension HasURIParameters {
    
    public func uriParameterWith(identifier: String) -> URIParameter? {
        return __URIParameterWith(array: uriParameters, identifier: identifier)
    }
    
    public func hasUriParameterWith(identifier: String) -> Bool {
        return has__URIParameterWith(array: uriParameters, identifier: identifier)
    }
    
}

    
public protocol HasBaseURIParameters: Has__URIParameters {
    
    var baseURIParameters: [URIParameter]? { get set }
    
}


public extension HasBaseURIParameters {
    
    public func baseURIParameterWith(identifier: String) -> URIParameter? {
        return __URIParameterWith(array: baseURIParameters, identifier: identifier)
    }
    
    public func hasBaseURIParameterWith(identifier: String) -> Bool {
        return has__URIParameterWith(array: baseURIParameters, identifier: identifier)
    }
    
}


public protocol HasQueryParameters: Has__URIParameters {
    
    var queryParameters: [URIParameter]? { get set }
    
}


public extension HasQueryParameters {
    
    public func queryParameterWith(identifier: String) -> URIParameter? {
        return __URIParameterWith(array: queryParameters, identifier: identifier)
    }
    
    public func hasQueryURIParameterWith(identifier: String) -> Bool {
        return has__URIParameterWith(array: queryParameters, identifier: identifier)
    }
    
}


// MARK: Default Values
public extension URIParameter {
    
    public convenience init(initWithDefaultsBasedOn uriParameter: URIParameter) {
        self.init()
        
        self.identifier     = uriParameter.identifier
        self.description    = uriParameter.description
        self.type           = uriParameter.type
        self.items          = uriParameter.items?.applyDefaults()
        self.uniqueItems    = uriParameter.uniqueItems
        self.enum           = uriParameter.enum
        self.required       = uriParameter.required
        self.example        = uriParameter.example
        self.minimum        = uriParameter.minimum
        self.maximum        = uriParameter.maximum
        self.default        = uriParameter.default
    }
    
    public func applyDefaults() -> URIParameter {
        return URIParameter(initWithDefaultsBasedOn: self)
    }
    
}

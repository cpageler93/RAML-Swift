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
        
        static func fromOptional(_ string: String?) -> ParameterType? {
            guard let string = string else { return nil }
            return ParameterType(rawValue: string)
        }
    }
    
    public class URIParameterItem {
        
        public enum ParameterItemType: String {
            case string
            case integer
        }
        
        public var type: ParameterItemType
        public var minLength: Int?
        
        init(type: ParameterItemType) {
            self.type = type
        }
    }
    
    public var identifier: String?
    public var description: String?
    public var type: ParameterType?
    public var items: [URIParameterItem]?
    
    public init(identifier: String? = nil,
                description: String? = nil,
                type: ParameterType? = nil,
                items: [URIParameterItem]? = nil) {
        self.identifier = identifier
        self.description = description
        self.type = type
        self.items = items
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
            
            let uriParameter = URIParameter(identifier: keyString,
                                            description: value["description"].string,
                                            type: URIParameter.ParameterType.fromOptional(value["type"].string),
                                            items: nil)
            // TODO: handle items
            
            uriParameters.append(uriParameter)
        }
        
        return uriParameters
    }
    
}



public protocol HasBaseURIParameters {
    
    var baseURIParameters: [URIParameter]? { get set }
    
}


public extension HasBaseURIParameters {
    
    public func baseURIParameterWith(identifier: String) -> URIParameter? {
        for baseURIParameter in baseURIParameters ?? [] {
            if baseURIParameter.identifier == identifier {
                return baseURIParameter
            }
        }
        return nil
    }
    
    public func hasBaseURIParameterWith(identifier: String) -> Bool {
        return baseURIParameterWith(identifier: identifier) != nil
    }
    
}

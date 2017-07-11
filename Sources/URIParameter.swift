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
    
    internal func parseURIParameters(_ yaml: [Yaml: Yaml]) throws -> [URIParameter] {
        var uriParameters: [URIParameter] = []
        
        for (key, value) in yaml {
            guard let keyString = key.string else {
                throw RAMLError.ramlParsingError(.invalidDataType(for: "URIParameter Key",
                                                                  mustBeKindOf: "String"))
            }
            
            var type: URIParameter.ParameterType? = nil
            if let typeString = value["type"].string {
                type = URIParameter.ParameterType(rawValue: typeString)
            }
            
            let uriParameter = URIParameter(identifier: keyString,
                                            description: value["description"].string,
                                            type: type,
                                            items: nil)
            uriParameters.append(uriParameter)
        }
        
        return uriParameters
    }
    
}

protocol HasUriParameters {
    
    
}
    <#requirements#>
}

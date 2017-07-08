//
//  SecurityScheme.swift
//  RAML
//
//  Created by Christoph Pageler on 08.07.17.
//

import Foundation
import Yaml

public enum SecuritySchemeType {
    
    case oAuth1
    case oAuth2
    case basicAuth
    case digestAuth
    case passThrough
    case xOther
    
}


public class SecurityScheme {
    
    public var identifier: String
    public var type: SecuritySchemeType
    public var displayName: String?
    public var description: String?
    public var describedBy: SecuritySchemeDescription?
    public var settings: SecuritySchemeSettings?
    
    public init(identifier: String, type: SecuritySchemeType) {
        self.identifier = identifier
        self.type = type
    }
    
}


// MARK: Parsing Security Schemes
internal extension RAML {
    
    func parseSecuritySchemes(_ yaml: [Yaml: Yaml]) throws -> [SecurityScheme] {
        var securitySchemes: [SecurityScheme] = []
        
        return securitySchemes
    }
    
}


public protocol HasSecuritySchemes {
    
    var securitySchemes: [SecurityScheme]? { get set }
    
}


public extension HasSecuritySchemes {
    
    public func securitySchemeWith(identifier: String) -> SecurityScheme? {
        return nil
    }
    
    public func hasSecuritySchemeWith(identifier: String) -> Bool {
        return securitySchemeWith(identifier: identifier) != nil
    }
    
}

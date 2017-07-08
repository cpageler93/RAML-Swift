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
    case xCustom
    
    static func fromString(_ string: String) throws -> SecuritySchemeType {
        switch string {
        case "OAuth 1.0": return .oAuth1
        case "OAuth 2.0": return .oAuth2
        case "Basic Authentication": return .basicAuth
        case "Digest Authentication": return .digestAuth
        case "Pass Through": return .passThrough
        case "x-custom": return .xCustom
            
        default: throw RAMLError.ramlParsingError(.invalidSecuritySchemeType(string))
        }
    }
    
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
        for (key, value) in yaml {
            guard let keyString = key.string else {
                throw RAMLError.ramlParsingError(.invalidDataType(for: "Security Scheme Key",
                                                                  mustBeKindOf: "String"))
            }
            let securityScheme = try parseSecurityScheme(identifier: keyString, yaml: value)
            securitySchemes.append(securityScheme)
        }
        return securitySchemes
    }
    
    private func parseSecurityScheme(identifier: String, yaml: Yaml) throws -> SecurityScheme {
        if let yamlDict = yaml.dictionary {
            guard let typeString = yamlDict["type"]?.string else {
                throw RAMLError.ramlParsingError(.missingValueFor(key: "type"))
            }
            let type = try SecuritySchemeType.fromString(typeString)
            let securityScheme = SecurityScheme(identifier: identifier, type: type)
            
            if let settingsYaml = yaml["settings"].dictionary {
                securityScheme.settings = try parseSecuritySchemeSettings(settingsYaml,
                                                                          forType: type)
            }
            
            if let describedByYaml = yaml["describedBy"].dictionary {
                securityScheme.describedBy = try parseSecuritySchemeDescription(describedByYaml)
            }
            
            
            return securityScheme
        } else if let yamlString = yaml.string {
            // TODO: add missing include
            return SecurityScheme(identifier: "NOT VALID", type: .basicAuth)
        }
        
        throw RAMLError.ramlParsingError(.failedParsingSecurityScheme)
    }
    
}


public protocol HasSecuritySchemes {
    
    var securitySchemes: [SecurityScheme]? { get set }
    
}


public extension HasSecuritySchemes {
    
    public func securitySchemeWith(identifier: String) -> SecurityScheme? {
        for securityScheme in securitySchemes ?? [] {
            if securityScheme.identifier == identifier {
                return securityScheme
            }
        }
        return nil
    }
    
    public func hasSecuritySchemeWith(identifier: String) -> Bool {
        return securitySchemeWith(identifier: identifier) != nil
    }
    
}

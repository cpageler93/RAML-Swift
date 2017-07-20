//
//  SecuritySchemeSettings.swift
//  RAML
//
//  Created by Christoph Pageler on 08.07.17.
//

import Foundation
import Yaml

public protocol SecuritySchemeSettings: HasAnnotations {
    
}


public class SecuritySchemeSettingsOAuth1: SecuritySchemeSettings {
    
    public var requestTokenUri: String?
    public var authorizationUri: String?
    public var tokenCredentialsUri: String?
    public var signatures: [String]?
    public var annotations: [Annotation]?
    
}


public class SecuritySchemeSettingsOAuth2: SecuritySchemeSettings {
    
    public var authorizationUri: String?
    public var accessTokenUri: String?
    public var authorizationGrants: [String]?
    public var scopes: [String]?
    public var annotations: [Annotation]?
}


// MARK: Parsing Security Scheme Settings
internal extension RAML {
    
    internal func parseSecuritySchemeSettings(_ input: ParseInput,
                                              forType type: SecuritySchemeType) throws -> SecuritySchemeSettings? {
        guard let yaml = input.yaml else { return nil }
        
        switch yaml {
        case .dictionary(let yamlDict):
            
            var settings = try parseSecuritySchemeSettings(dict: yamlDict, forType: type)
            settings.annotations = try parseAnnotations(input)
            return settings
            
        default:
            return nil
        }
        
    }
    
    private func parseSecuritySchemeSettings(dict: [Yaml: Yaml],
                                             forType type: SecuritySchemeType) throws -> SecuritySchemeSettings {
        switch type {
        case .oAuth1: return try parseSecuritySchemeSettingsOauth1(dict: dict)
        case .oAuth2: return try parseSecuritySchemeSettingsOauth2(dict: dict)
        default: throw RAMLError.ramlParsingError(.settingsNotAvailableFor("Security scheme type `\(type)`"))
        }
    }
    
    private func parseSecuritySchemeSettingsOauth1(dict: [Yaml: Yaml]) throws -> SecuritySchemeSettingsOAuth1 {
        let settings = SecuritySchemeSettingsOAuth1()
        
        settings.requestTokenUri        = dict["requestTokenUri"]?.string
        settings.authorizationUri       = dict["authorizationUri"]?.string
        settings.tokenCredentialsUri    = dict["tokenCredentialsUri"]?.string
        
        if let signaturesYaml = dict["signatures"]?.array {
            var signatures: [String] = []
            for signatureYaml in signaturesYaml {
                guard let signatureString = signatureYaml.string else {
                    throw RAMLError.ramlParsingError(.invalidDataType(for: "Signature",
                                                                      mustBeKindOf: "String"))
                }
                signatures.append(signatureString)
            }
            settings.signatures = signatures
        }
        
        return settings
    }
    
    private func parseSecuritySchemeSettingsOauth2(dict: [Yaml: Yaml]) throws -> SecuritySchemeSettingsOAuth2 {
        let settings = SecuritySchemeSettingsOAuth2()
        
        settings.authorizationUri = dict["authorizationUri"]?.string
        settings.accessTokenUri = dict["accessTokenUri"]?.string
        
        if let authorizationGrantsYaml = dict["authorizationGrants"]?.array {
            var authorizationGrants: [String] = []
            for authorizationGrantYaml in authorizationGrantsYaml {
                guard let authorizationGrantString = authorizationGrantYaml.string else {
                    throw RAMLError.ramlParsingError(.invalidDataType(for: "Authorization Grant",
                                                                      mustBeKindOf: "String"))
                }
                authorizationGrants.append(authorizationGrantString)
            }
            settings.authorizationGrants = authorizationGrants
        }
        
        return settings
    }
    
}

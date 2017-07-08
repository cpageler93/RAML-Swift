//
//  SecuritySchemeSettings.swift
//  RAML
//
//  Created by Christoph Pageler on 08.07.17.
//

import Foundation
import Yaml

public protocol SecuritySchemeSettings {
    
}


public class SecuritySchemeSettingsOAuth1: SecuritySchemeSettings {
    
    var requestTokenUri: String?
    var authorizationUri: String?
    var tokenCredentialsUri: String?
    var signatures: [String]?
    
}


public class SecuritySchemeSettingsOAuth2: SecuritySchemeSettings {
    
    var authorizationUri: String?
    var accessTokenUri: String?
    var authorizationGrants: [String]?
    var scopes: [String]?
}


// MARK: Parsing Security Scheme Settings
internal extension RAML {
    
    internal func parseSecuritySchemeSettings(_ yaml: [Yaml: Yaml],
                                              forType type: SecuritySchemeType) throws -> SecuritySchemeSettings {
        switch type {
        case .oAuth1: return try parseSecuritySchemeSettingsOauth1(yaml: yaml)
        case .oAuth2: return try parseSecuritySchemeSettingsOauth2(yaml: yaml)
        default: throw RAMLError.ramlParsingError(.settingsNotAvailableFor("Security scheme type `\(type)`"))
        }
    }
    
    private func parseSecuritySchemeSettingsOauth1(yaml: [Yaml: Yaml]) throws -> SecuritySchemeSettingsOAuth1 {
        let settings = SecuritySchemeSettingsOAuth1()
        
        settings.requestTokenUri = yaml["requestTokenUri"]?.string
        settings.authorizationUri = yaml["authorizationUri"]?.string
        settings.tokenCredentialsUri = yaml["tokenCredentialsUri"]?.string
        
        if let signaturesYaml = yaml["signatures"]?.array {
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
    
    private func parseSecuritySchemeSettingsOauth2(yaml: [Yaml: Yaml]) throws -> SecuritySchemeSettingsOAuth2 {
        let settings = SecuritySchemeSettingsOAuth2()
        
        settings.authorizationUri = yaml["authorizationUri"]?.string
        settings.accessTokenUri = yaml["accessTokenUri"]?.string
        
        if let authorizationGrantsYaml = yaml["authorizationGrants"]?.array {
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

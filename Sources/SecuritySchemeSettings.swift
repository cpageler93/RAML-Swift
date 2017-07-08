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

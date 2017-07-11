//
//  SecuritySchemeTests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 08.07.17.
//

import XCTest
@testable import RAML

class SecuritySchemeTests: XCTestCase {
    
    func testIncludes() {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "security_includes", ofType: "raml", inDirectory: "TestData/Includes") else {
            XCTFail()
            return
        }
        guard let raml = try? RAML(file: path) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let securitySchemes = raml.securitySchemes else {
            XCTFail("No Security Schemes")
            return
        }
        XCTAssertEqual(securitySchemes.count, 2)
        
        // OAuth 1.0
        guard let oauth1SecurityScheme = raml.securitySchemeWith(identifier: "oauth_1_0") else {
            XCTFail("No OAuth1 Scheme")
            return
        }
        
        XCTAssertEqual(oauth1SecurityScheme.type, .oAuth1)
        guard let oAuth1Settings = oauth1SecurityScheme.settings as? SecuritySchemeSettingsOAuth1 else {
            XCTFail("No OAuth1 Settings")
            return
        }
        
        XCTAssertEqual(oAuth1Settings.requestTokenUri, "https://api.dropbox.com/1/oauth/request_token")
        XCTAssertEqual(oAuth1Settings.authorizationUri, "https://www.dropbox.com/1/oauth/authorize")
        XCTAssertEqual(oAuth1Settings.tokenCredentialsUri, "https://api.dropbox.com/1/oauth/access_token")
        XCTAssertNil(oAuth1Settings.signatures)
        
        
        // OAuth 2.0
        guard let oauth2SecurityScheme = raml.securitySchemeWith(identifier: "oauth_2_0") else {
            XCTFail("No OAuth2 Scheme")
            return
        }
        
        XCTAssertEqual(oauth2SecurityScheme.type, .oAuth2)
        
        guard let authHeader = oauth2SecurityScheme.describedBy?.headerWith(key: "Authorization") else {
            XCTFail("No Auth Header")
            return
        }
        XCTAssertEqual(authHeader.type, .string)
        
        // query params
        
        XCTAssertTrue(oauth2SecurityScheme.describedBy?.hasResponseWith(code: 401) ?? false)
        XCTAssertTrue(oauth2SecurityScheme.describedBy?.hasResponseWith(code: 403) ?? false)
        
        guard let oAuth2Settings = oauth2SecurityScheme.settings as? SecuritySchemeSettingsOAuth2 else {
            XCTFail("No OAuth2 Settings")
            return
        }
        
        XCTAssertEqual(oAuth2Settings.authorizationUri, "https://www.dropbox.com/1/oauth2/authorize")
        XCTAssertEqual(oAuth2Settings.accessTokenUri, "https://api.dropbox.com/1/oauth2/token")
        XCTAssertTrue(oAuth2Settings.authorizationGrants?.contains("authorization_code") ?? false)
        XCTAssertTrue(oAuth2Settings.authorizationGrants?.contains("implicit") ?? false)
    }
    
    func testOauth1Settings() {
        let ramlString =
        """
        #%RAML 1.0
        title: My Sample API
        securitySchemes:
          oauth_1_0:
            description: |
              OAuth 1.0 continues to be supported for all API requests, but OAuth 2.0 is now preferred.
            type: OAuth 1.0
            settings:
              requestTokenUri: https://api.mysampleapi.com/1/oauth/request_token
              authorizationUri: https://api.mysampleapi.com/1/oauth/authorize
              tokenCredentialsUri: https://api.mysampleapi.com/1/oauth/access_token
              signatures: [ 'HMAC-SHA1', 'PLAINTEXT' ]
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let securitySchemes = raml.securitySchemes else {
            XCTFail("No Security Schemes")
            return
        }
        XCTAssertEqual(securitySchemes.count, 1)
        
        guard let oauth1SecurityScheme = raml.securitySchemeWith(identifier: "oauth_1_0") else {
            XCTFail("No OAuth1 Scheme")
            return
        }
        
        XCTAssertEqual(oauth1SecurityScheme.type, .oAuth1)
        guard let oAuth1Settings = oauth1SecurityScheme.settings as? SecuritySchemeSettingsOAuth1 else {
            XCTFail("No OAuth1 Settings")
            return
        }
        
        XCTAssertEqual(oAuth1Settings.requestTokenUri, "https://api.mysampleapi.com/1/oauth/request_token")
        XCTAssertEqual(oAuth1Settings.authorizationUri, "https://api.mysampleapi.com/1/oauth/authorize")
        XCTAssertEqual(oAuth1Settings.tokenCredentialsUri, "https://api.mysampleapi.com/1/oauth/access_token")
        XCTAssertTrue(oAuth1Settings.signatures?.contains("HMAC-SHA1") ?? false)
        XCTAssertTrue(oAuth1Settings.signatures?.contains("PLAINTEXT") ?? false)
    }
    
    func testOauth2Settings() {
        let ramlString =
        """
        #%RAML 1.0
        title: Dropbox API
        version: 1
        baseUri: https://api.dropbox.com/{version}
        securitySchemes:
          oauth_2_0:
            description: |
              Dropbox supports OAuth 2.0 for authenticating all API requests.
            type: OAuth 2.0
            describedBy:
              headers:
                Authorization:
                  description: |
                     Used to send a valid OAuth 2 access token. Do not use
                     with the "access_token" query string parameter.
                  type: string
              queryParameters:
                access_token:
                  description: |
                     Used to send a valid OAuth 2 access token. Do not use with
                     the "Authorization" header.
                  type: string
              responses:
                401:
                  description: |
                      Bad or expired token. This can happen if the user or Dropbox
                      revoked or expired an access token. To fix, re-authenticate
                      the user.
                403:
                  description: |
                      Bad OAuth request (wrong consumer key, bad nonce, expired
                      timestamp...). Unfortunately, re-authenticating the user won't help here.
            settings:
              authorizationUri: https://www.dropbox.com/1/oauth2/authorize
              accessTokenUri: https://api.dropbox.com/1/oauth2/token
              authorizationGrants: [ authorization_code, implicit, 'urn:ietf:params:oauth:grant-type:saml2-bearer' ]
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let securitySchemes = raml.securitySchemes else {
            XCTFail("No Security Schemes")
            return
        }
        XCTAssertEqual(securitySchemes.count, 1)
        
        guard let oauth2SecurityScheme = raml.securitySchemeWith(identifier: "oauth_2_0") else {
            XCTFail("No OAuth2 Scheme")
            return
        }
        
        XCTAssertEqual(oauth2SecurityScheme.type, .oAuth2)
        
        guard let authHeader = oauth2SecurityScheme.describedBy?.headerWith(key: "Authorization") else {
            XCTFail("No Auth Header")
            return
        }
        XCTAssertEqual(authHeader.type, .string)
        
        // query params
        
        XCTAssertTrue(oauth2SecurityScheme.describedBy?.hasResponseWith(code: 401) ?? false)
        XCTAssertTrue(oauth2SecurityScheme.describedBy?.hasResponseWith(code: 403) ?? false)
        
        guard let oAuth2Settings = oauth2SecurityScheme.settings as? SecuritySchemeSettingsOAuth2 else {
            XCTFail("No OAuth2 Settings")
            return
        }
        
        XCTAssertEqual(oAuth2Settings.authorizationUri, "https://www.dropbox.com/1/oauth2/authorize")
        XCTAssertEqual(oAuth2Settings.accessTokenUri, "https://api.dropbox.com/1/oauth2/token")
        XCTAssertTrue(oAuth2Settings.authorizationGrants?.contains("authorization_code") ?? false)
        XCTAssertTrue(oAuth2Settings.authorizationGrants?.contains("implicit") ?? false)
        XCTAssertTrue(oAuth2Settings.authorizationGrants?.contains("urn:ietf:params:oauth:grant-type:saml2-bearer") ?? false)
    }
    
    func testBasicAuthentication() {
        let ramlString =
        """
        #%RAML 1.0
        title: Dropbox API
        version: 1
        baseUri: https://api.dropbox.com/{version}
        securitySchemes:
          basic:
            description: |
              This API supports Basic Authentication.
            type: Basic Authentication
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let securitySchemes = raml.securitySchemes else {
            XCTFail("No Security Schemes")
            return
        }
        XCTAssertEqual(securitySchemes.count, 1)
        
        guard let basicScheme = raml.securitySchemeWith(identifier: "basic") else {
            XCTFail("No Basic Scheme")
            return
        }
        XCTAssertEqual(basicScheme.type, .basicAuth)
    }
    
    func testDigestAuthentication() {
        let ramlString =
        """
        #%RAML 1.0
        title: Dropbox API
        version: 1
        baseUri: https://api.dropbox.com/{version}
        securitySchemes:
          digest:
            description: |
              This API supports DigestSecurityScheme Authentication.
            type: Digest Authentication
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let securitySchemes = raml.securitySchemes else {
            XCTFail("No Security Schemes")
            return
        }
        XCTAssertEqual(securitySchemes.count, 1)
        
        guard let digestScheme = raml.securitySchemeWith(identifier: "digest") else {
            XCTFail("No Digest Scheme")
            return
        }
        XCTAssertEqual(digestScheme.type, .digestAuth)
    }
    
    func testPassThrough() {
        let ramlString =
        """
        #%RAML 1.0
        title: Dropbox API
        version: 1
        baseUri: https://api.dropbox.com/{version}
        securitySchemes:
          passthrough:
            description: |
              This API supports Pass Through Authentication.
            type: Pass Through
            describedBy:
              queryParameters:
                query:
                  type: string
              headers:
                api_key:
                  type: string
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let securitySchemes = raml.securitySchemes else {
            XCTFail("No Security Schemes")
            return
        }
        XCTAssertEqual(securitySchemes.count, 1)
        
        guard let passThroughScheme = raml.securitySchemeWith(identifier: "passthrough") else {
            XCTFail("No Pass Through Scheme")
            return
        }
        XCTAssertEqual(passThroughScheme.type, .passThrough)
        
        //            passThroughScheme.describedBy.queryParams
        
        guard let apiKeyHeader = passThroughScheme.describedBy?.headerWith(key: "api_key") else {
            XCTFail("No api_key header")
            return
        }
        XCTAssertEqual(apiKeyHeader.type, .string)
    }
    
    func testXCustom() {
        let ramlString =
        """
        #%RAML 1.0
        title: Custom API
        version: 1
        baseUri: https://api.custom.com/{version}
        securitySchemes:
          custom_scheme:
            description: |
              A custom security scheme for authenticating requests.
            type: x-custom
            describedBy:
              headers:
                SpecialToken:
                  description: |
                    Used to send a custom token.
                  type: string
              responses:
                401:
                  description: |
                    Bad token.
                403:
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let securitySchemes = raml.securitySchemes else {
            XCTFail("No Security Schemes")
            return
        }
        XCTAssertEqual(securitySchemes.count, 1)
        
        guard let customScheme = raml.securitySchemeWith(identifier: "custom_scheme") else {
            XCTFail("No Custom scheme")
            return
        }
        XCTAssertEqual(customScheme.type, .xCustom)
        
        guard let specialTokenHeader = customScheme.describedBy?.headerWith(key: "SpecialToken") else {
            XCTFail("No Special Token Header")
            return
        }
        
        XCTAssertEqual(specialTokenHeader.type, .string)
        
        XCTAssertTrue(customScheme.describedBy?.hasResponseWith(code: 401) ?? false)
        XCTAssertTrue(customScheme.describedBy?.hasResponseWith(code: 403) ?? false)
    }
    
}

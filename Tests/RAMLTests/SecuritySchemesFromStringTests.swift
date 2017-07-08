//
//  SecuritySchemesFromStringTests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 08.07.17.
//

import XCTest
@testable import RAML

class SecuritySchemesFromStringTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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
        
        do {
            let raml = try RAML(string: ramlString)
            XCTAssertEqual(raml.securitySchemes?.count, 1)
            
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
        } catch {
            XCTFail("This should not fail")
        }
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
        XCTFail()
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
        
        XCTFail()
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
        
        XCTFail()
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
        
        XCTFail()
    }
    
    func testXOther() {
        let raml =
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
        
        XCTFail()
    }
    
}

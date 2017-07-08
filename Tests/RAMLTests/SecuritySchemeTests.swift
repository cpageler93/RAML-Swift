//
//  SecuritySchemeTests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 08.07.17.
//

import XCTest
@testable import RAML

class SecuritySchemeTests: XCTestCase {
    
    var raml: RAML!
    
    override func setUp() {
        super.setUp()
        
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "security_includes",
                                     ofType: "raml",
                                     inDirectory: "TestData/Includes") else {
                                        XCTFail()
                                        return
        }
        do {
            raml = try RAML(file: path)
        } catch {
            XCTFail()
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIncludes() {
        XCTAssertEqual(raml.securitySchemes?.count, 2)
    }
    
    func testOauth1() {
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
    }
    
    func testOauth2() {
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
    
}

//
//  SecuritySchemeUsageTests.swift
//  RAMLTests
//
//  Created by Christoph on 12.07.17.
//

import XCTest
@testable import RAML

class SecuritySchemeUsageTests: XCTestCase {
    
    func testSecuritySchemeUsagesInRoot() {
        let ramlString =
        """
        #%RAML 1.0
        title: GitHub API
        securedBy: [oauth_2_0]
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let securitySchemeUsages = raml.securedBy else {
            XCTFail("No Security Schemes")
            return
        }
        XCTAssertEqual(securitySchemeUsages.count, 1)
        
        guard let oauth = raml.securitySchemeUsageWith(identifier: "oauth_2_0") else {
            XCTFail("No oauth security scheme")
            return
        }
        
        XCTAssertNil(oauth.parameters)
    }
    
    func testSecuritySchemeUsagesInRessources() {
        let ramlString =
        """
        #%RAML 1.0
        title: GitHub API
        version: v3
        /users/{userid}/gists:
          get:
            securedBy: [null, oauth_2_0]
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let resource = raml.resourceWith(path: "/users/{userid}/gists")?.methodWith(type: .get) else {
            XCTFail("Resource not found")
            return
        }
        
        guard let securitySchemeUsages = resource.securedBy else {
            XCTFail("No Security Schemes")
            return
        }
        XCTAssertEqual(securitySchemeUsages.count, 2)
        
        guard let nullSecurityScheme = resource.securitySchemeUsageWith(identifier: "null") else {
            XCTFail("No null security scheme")
            return
        }
        XCTAssertNil(nullSecurityScheme.parameters)
        
        guard let oauth = resource.securitySchemeUsageWith(identifier: "oauth_2_0") else {
            XCTFail("No oauth security scheme")
            return
        }
        XCTAssertNil(oauth.parameters)
    }
    
    func testSecuritySchemeUsagesInRessourcesWithParameters() {
        let ramlString =
        """
        #%RAML 1.0
        title: GitHub API
        /users/{userid}/gists:
          get:
            securedBy: [null, oauth_2_0: { scopes: [ ADMINISTRATOR ] } ]
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let resource = raml.resourceWith(path: "/users/{userid}/gists")?.methodWith(type: .get) else {
            XCTFail("Resource not found")
            return
        }
        
        guard let securitySchemeUsages = resource.securedBy else {
            XCTFail("No Security Schemes")
            return
        }
        XCTAssertEqual(securitySchemeUsages.count, 2)
        
        guard let nullSecurityScheme = resource.securitySchemeUsageWith(identifier: "null") else {
            XCTFail("No null security scheme")
            return
        }
        XCTAssertNil(nullSecurityScheme.parameters)
        
        guard let oauth = resource.securitySchemeUsageWith(identifier: "oauth_2_0") else {
            XCTFail("No oauth security scheme")
            return
        }
        XCTAssertNotNil(oauth.parameters)
    }
    
}

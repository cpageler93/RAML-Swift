//
//  TraitsFromStringTests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 02.07.17.
//

import XCTest
@testable import RAML

class TraitsFromStringTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBasicTraits() {
        let ramlString =
        """
        #%RAML 1.0
        title: Example with headers
        traits:
          chargeable:
            headers:
              X-Dept:
                type: array
                description: |
                  A department code to be charged.
                  Multiple of such headers are allowed.
                items:
                  pattern: ^\\d+\\-\\w+$
                  example: 230-OCTO
          traceable:
            headers:
              X-Tracker:
                description: A code to track API calls end to end
                pattern: ^\\w{16}$
                example: abcdefghijklmnop
        /users:
          get:
            is: [ chargeable, traceable ]
            description: |
              The HTTP interaction will look like

              GET /users HTTP/1.1
              X-Dept: 18-FINANCE
              X-Dept: 200-MISC
              X-Tracker: gfr456d03ygh38s2
            headers:
              X-Dept:
                example: [ 18-FINANCE, 200-MISC ]
              X-Tracker:
                example: gfr456d03ygh38s2
        """
        
        do {
            let raml = try RAML(string: ramlString)
            guard let chargeableTrait = raml.traitDefinitionWith(name: "chargeable") else {
                XCTFail()
                return
            }
            
            guard let traceableTrait = raml.traitDefinitionWith(name: "traceable") else {
                XCTFail()
                return
            }
            
            guard let usersResource = raml.resourceWith(path: "/users") else {
                XCTFail()
                return
            }
            
            guard let usersGetMethod = usersResource.methodWith(type: .get) else {
                XCTFail()
                return
            }
            
            
            XCTAssertTrue(usersGetMethod.hasTraitUsageWith(name: "chargeable"))
            XCTAssertTrue(usersGetMethod.hasTraitUsageWith(name: "traceable"))
            
        } catch {
            XCTFail()
        }
    }
    
    func testTraitsWithParameters() {
        let ramlString =
        """
        #%RAML 1.0
        title: Example API
        version: v1
        resourceTypes:
          apiResource:
            get:
              is: [ { secured : { tokenName: access_token } } ]
        traits:
          secured:
            queryParameters:
              <<tokenName>>:
                description: A valid <<tokenName>> is required
        /servers1:
          get:
            is: [ { secured : { tokenName: token } } ]
        /servers2:
          get:
            is: [ secured: { tokenName: access_token }, paged: { maxPages: 10 } ]
        """
        
        do {
            let raml = try RAML(string: ramlString)
            
            guard let serversResource = raml.resourceWith(path: "/servers1") else {
                XCTFail()
                return
            }
            
            guard let getServersMethod = serversResource.methodWith(type: .get) else {
                XCTFail()
                return
            }
            
            guard let traitUsage = getServersMethod.traitUsageWith(name: "secured") else {
                XCTFail()
                return
            }
            
            guard let tokenNameValue = traitUsage.parameterFor(key: "tokenName")?.string else {
                XCTFail()
                return
            }
            XCTAssertEqual(tokenNameValue, "token")
            
            
        } catch {
            XCTFail()
        }
    }
}


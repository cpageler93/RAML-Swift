//
//  ResourcesFromStringTests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 30.06.17.
//

import XCTest
@testable import RAML

class ResourcesFromStringTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testParseMediaTypeOverriding() {
        let ramlString =
        """
        #%RAML 1.0
        title: New API
        mediaType: [ application/json, application/xml ]
        types:
          Person:
          Another:
        /list:
          get:
            responses:
              200:
                body: Person[]
        /send:
          post:
            body:
              application/json:
                type: Another
        """
        
        do {
            let raml = try RAML(string: ramlString)
            XCTAssertEqual(raml.resources?.count, 2)
            
            guard let listResource = raml.resourceWith(path: "/list") else {
                XCTFail()
                return
            }
            XCTAssertNil(listResource.annotations)
            XCTAssertNil(listResource.description)
            XCTAssertNil(listResource.displayName)
            XCTAssertEqual(listResource.methods?.count, 1)
            
            guard let listGet = listResource.methodWith(type: .get) else {
                XCTFail()
                return
            }
            
            guard let sendResource = raml.resourceWith(path: "/send") else {
                XCTFail()
                return
            }
            XCTAssertNil(sendResource.annotations)
            XCTAssertNil(sendResource.description)
            XCTAssertNil(sendResource.displayName)
            XCTAssertEqual(sendResource.methods?.count, 1)
            
        } catch {
            XCTFail()
        }
    }
    
    func testParseHeaders() {
        let ramlString =
        """
        #%RAML 1.0
        title: ZEncoder API
        version: v2
        baseUri: https://app.zencoder.com/api/{version}
        /jobs:
          post:
            description: Create a job
            headers:
              Zencoder-Api-Key:
                description: The API key needed to create a new job
        """
        do {
            let raml = try RAML(string: ramlString)
            guard let jobsResource = raml.resourceWith(path: "/jobs") else {
                XCTFail()
                return
            }
            
            guard let postMethod = jobsResource.methodWith(type: .post) else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(postMethod.headers?.count, 1)
            guard let apiKeyHeader = postMethod.headerWith(key: "Zencoder-Api-Key") else {
                XCTFail("api key header should not be nil")
                return
            }
            
            XCTAssertEqual(apiKeyHeader.description, "The API key needed to create a new job")
            
        } catch {
            XCTFail()
        }
        
    }
    
    func testParseHeadersWithArrayAndPatterns() {
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
            
            guard let XDeptHeader = chargeableTrait.headerWith(key: "X-Dept") else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(XDeptHeader.type, .array)
            XCTAssertGreaterThan(XDeptHeader.description?.characters.count ?? 0, 10)
            guard let XDeptHeaderItems = XDeptHeader.items else {
                XCTFail()
                return
            }
            XCTAssertEqual(XDeptHeaderItems.pattern, "^\\d+\\-\\w+$")
            XCTAssertEqual(XDeptHeaderItems.example, "230-OCTO")
            
            // TODO: match with example from resourcs
            
        } catch {
            XCTFail()
        }
    }
}

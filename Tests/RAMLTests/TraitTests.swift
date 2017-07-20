//
//  TraitTests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 02.07.17.
//

import XCTest
@testable import RAML

class TraitTests: XCTestCase {
    
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
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let traits = raml.traitDefinitions else {
            XCTFail("No Traits")
            return
        }
        XCTAssertEqual(traits.count, 2)
        
        guard let chargeableTrait = raml.traitDefinitionWith(name: "chargeable") else {
            XCTFail("No Chargeable Trait")
            return
        }
        XCTAssertNil(chargeableTrait.description)
        XCTAssertNil(chargeableTrait.usage)
        
        guard let chargeableTraitHeaders = chargeableTrait.headers else {
            XCTFail("No Headers in Chargeable Trait")
            return
        }
        XCTAssertEqual(chargeableTraitHeaders.count, 1)
        
        guard let xDeptHeader = chargeableTrait.headerWith(key: "X-Dept") else {
            XCTFail("No X-Dept Header in Chargeable Trait")
            return
        }
        
        XCTAssertEqual(xDeptHeader.type, HeaderType.array)
        XCTAssertNotNil(xDeptHeader.description)
        XCTAssertNil(xDeptHeader.required)
        
        guard let xDeptHeaderItems = xDeptHeader.items else {
            XCTFail("No Items in X-Dept Header")
            return
        }
        
        XCTAssertEqual(xDeptHeaderItems.pattern, "^\\d+\\-\\w+$")
        XCTAssertEqual(xDeptHeaderItems.example, "230-OCTO")
        
        
        //
        // traceable:
        //   headers:
        //     X-Tracker:
        //       description: A code to track API calls end to end
        //       pattern: ^\\w{16}$
        //       example: abcdefghijklmnop
        //
        guard let traceableTrait = raml.traitDefinitionWith(name: "traceable") else {
            XCTFail("No Traceable Trait")
            return
        }
        XCTAssertNil(traceableTrait.description)
        XCTAssertNil(traceableTrait.usage)
        
        guard let traceableHeaders = traceableTrait.headers else {
            XCTFail("No Headers in Traceable Trait")
            return
        }
        XCTAssertEqual(traceableHeaders.count, 1)
        
        guard let xTrackerHeader = traceableTrait.headerWith(key: "X-Tracker") else {
            XCTFail("No X-Tracker Header")
            return
        }
        
        XCTAssertNil(xTrackerHeader.items)
        XCTAssertNil(xTrackerHeader.required)
        XCTAssertEqual(xTrackerHeader.description, "A code to track API calls end to end")
        XCTAssertEqual(xTrackerHeader.pattern, "^\\w{16}$")
        XCTAssertEqual(xTrackerHeader.example, "abcdefghijklmnop")
    }
    
    func testTraitsWithParameters() {
        let ramlString =
        """
        #%RAML 1.0
        title: Example API
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
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let apiResourceTypeGet = raml.resourceTypeWith(identifier: "apiResource")?.methodWith(type: .get) else {
            XCTFail("No GET in apiResource ResourceType")
            return
        }
        guard let securedTraitUsage = apiResourceTypeGet.traitUsageWith(name: "secured") else {
            XCTFail("No secured trait usage in GET")
            return
        }
        XCTAssertEqual(securedTraitUsage.parameterFor(key: "tokenName")?.string, "access_token")
        
        guard let securedTrait = raml.traitDefinitionWith(name: "secured") else {
            XCTFail("No secured trait")
            return
        }
        XCTAssertEqual(securedTrait.queryParameters?.count ?? 0, 1)
        guard let tokenNameParameter = securedTrait.queryParameterWith(identifier: "<<tokenName>>") else {
            XCTFail("No <<tokenName>> query Parameter")
            return
        }
        XCTAssertEqual(tokenNameParameter.description, "A valid <<tokenName>> is required")
        
        
        guard let servers1Get = raml.resourceWith(path: "/servers1")?.methodWith(type: .get) else {
            XCTFail("no GET /servers1 resource")
            return
        }
        
        guard let servers1GetSecuredTrait = servers1Get.traitUsageWith(name: "secured") else {
            XCTFail("No secured trait for GET /servers1")
            return
        }
        
        guard let server1GetSecuredTraitParameters = servers1GetSecuredTrait.parameters else {
            XCTFail("No Parameters in secure trait for GET /servers1")
            return
        }
        XCTAssertEqual(server1GetSecuredTraitParameters.count, 1)
        XCTAssertTrue(servers1GetSecuredTrait.hasParameterFor(key: "tokenName"))
        XCTAssertEqual(servers1GetSecuredTrait.parameterFor(key: "tokenName")?.string, "token")
        
        
        
        guard let servers2Get = raml.resourceWith(path: "/servers2")?.methodWith(type: .get) else {
            XCTFail("no GET /servers2 resource")
            return
        }
        
        guard let servers2GetSecuredTrait = servers2Get.traitUsageWith(name: "secured") else {
            XCTFail("No secured trait for GET /servers2")
            return
        }
        
        guard let servers2GetSecuredTraitParameters = servers2GetSecuredTrait.parameters else {
            XCTFail("No Parameters in secure trait for GET /servers2")
            return
        }
        
        XCTAssertEqual(servers2GetSecuredTraitParameters.count, 1)
        XCTAssertTrue(servers2GetSecuredTrait.hasParameterFor(key: "tokenName"))
        XCTAssertEqual(servers2GetSecuredTrait.parameterFor(key: "tokenName")?.string, "access_token")
        
        guard let servers2GetPagedTrait = servers2Get.traitUsageWith(name: "paged") else {
            XCTFail("No paged trait for GET /servers2")
            return
        }
        
        guard let servers2GetPagedTraitParameters = servers2GetPagedTrait.parameters else {
            XCTFail("No Parameters in paged trait for GET /servers2")
            return
        }
        
        XCTAssertEqual(servers2GetPagedTraitParameters.count, 1)
        XCTAssertTrue(servers2GetPagedTrait.hasParameterFor(key: "maxPages"))
        XCTAssertEqual(servers2GetPagedTrait.parameterFor(key: "maxPages")?.int, 10)
    }
}


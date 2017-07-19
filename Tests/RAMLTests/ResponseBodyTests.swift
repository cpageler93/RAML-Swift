//
//  ResponseBodyTests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 19.07.17.
//

import XCTest
@testable import RAML

class ResponseBodyTests: XCTestCase {
    
    func testResponseBodies() {
        let ramlString =
        """
        #%RAML 1.0
        title: Example of request bodies
        mediaType: application/json
        types:
          User:
            properties:
              firstName:
              lastName:
        /users:
          post:
            body:
              type: User
        /groups:
          post:
            body:
              application/json:
                properties:
                  groupName:
                  deptCode:
                    type: number
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let usersPostBody = raml.resourceWith(path: "/users")?.methodWith(type: .post)?.body else {
            XCTFail("No /users POST body")
            return
        }
        XCTAssertEqual(usersPostBody.type, DataType.custom(type: "User"))
        XCTAssertNil(usersPostBody.properties)
        XCTAssertNil(usersPostBody.examples)
        XCTAssertNil(usersPostBody.mediaTypes)
        
        guard let groupsPostBody = raml.resourceWith(path: "/groups")?.methodWith(type: .post)?.body else {
            XCTFail("No /groups POST body")
            return
        }
        XCTAssertNil(groupsPostBody.type)
        XCTAssertNil(groupsPostBody.properties)
        XCTAssertNil(groupsPostBody.examples)
        XCTAssertNotNil(groupsPostBody.mediaTypes)
        guard let groupsPostBodyMediatypes = groupsPostBody.mediaTypes else {
            XCTFail("No media Types for /groups POST body")
            return
        }
        XCTAssertEqual(groupsPostBodyMediatypes.count, 1)
        
        guard let json = groupsPostBody.mediaTypeWith(identifier: "application/json") else {
            XCTFail("No application/json")
            return
        }
        XCTAssertNil(json.type)
        XCTAssertNil(json.examples)
        XCTAssertNotNil(json.properties)
        
    }
}

//
//  RAMLPreprocessorTests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 08.07.17.
//

import XCTest
@testable import RAML

class RAMLPreprocessorTests: XCTestCase {
    
    func testPreprocessorRoutes() {
        let ramlString =
        """
        #%RAML 1.0
        title: Example with headers
        /users:
          displayName: Users
          /me:
            displayName: Me
            /followers:
              displayName: My Followers
          /{userId}:
            uriParameters:
              userId:
                type: integer
            /followers:
              displayName: Followers of Specific User
        """
        
        let expectedRoutes =
        """
        GET /users                      Users
        GET /users/me                   Me
        GET /users/me/followers         My Followers
        GET /users/{userId}
        GET /users/{userId}/followers   Followers of Specific User
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        let prep = RAMLPreprocessor(raml: raml)
        let routes = prep.routes()
        
        XCTAssertEqual(routes, expectedRoutes)
    }
    
}

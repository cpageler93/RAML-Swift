//
//  RouteTests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 08.07.17.
//

import XCTest
@testable import RAML

class RouteTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBasicRoutes() {
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
        
        do {
            let raml = try RAML(string: ramlString)
            let routes = raml.routes()
            
            XCTAssertEqual(routes, expectedRoutes)
        } catch {
            XCTFail("This should not fail")
        }
    }
    
}

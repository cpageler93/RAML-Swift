//
//  ResourceTypeTests.swift
//  RAMLTests
//
//  Created by Christoph on 12.07.17.
//

import XCTest
@testable import RAML

class ResourceTypeTests: XCTestCase {
    
    func testResourceTypesDeclaration() {
        
        let ramlString =
        """
        #%RAML 1.0
        title: Example API
        resourceTypes:
          collection:
            usage: This resourceType should be used for any collection of items
            description: The collection of <<resourcePathName>>
            get:
              description: Get all <<resourcePathName>>, optionally filtered
            post:
              description: Create a new <<resourcePathName | !singularize>>
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let resourceTypes = raml.resourceTypes else {
            XCTFail("No Resource Types")
            return
        }
        XCTAssertEqual(resourceTypes.count, 1)
        
        guard let collectionResourceType = raml.resourceTypeWith(identifier: "collection") else {
            XCTFail("No Collection Resource Type")
            return
        }
        
        XCTAssertEqual(collectionResourceType.usage, "This resourceType should be used for any collection of items")
        XCTAssertEqual(collectionResourceType.description, "The collection of <<resourcePathName>>")
        
        guard let methods = collectionResourceType.methods else {
            XCTFail("No Methods")
            return
        }
        XCTAssertEqual(methods.count, 2)
        
        guard let getMethod = collectionResourceType.methodWith(type: .get) else {
            XCTFail("No GET Method")
            return
        }
        XCTAssertEqual(getMethod.description, "Get all <<resourcePathName>>, optionally filtered")
        XCTAssertNil(getMethod.annotations)
        XCTAssertNil(getMethod.body)
        XCTAssertNil(getMethod.displayName)
        XCTAssertNil(getMethod.headers)
        XCTAssertNil(getMethod.responses)
        XCTAssertNil(getMethod.traitUsages)
        
        guard let postMethod = collectionResourceType.methodWith(type: .post) else {
            XCTFail("No POST Method")
            return
        }
        XCTAssertEqual(postMethod.description, "Create a new <<resourcePathName | !singularize>>")
        XCTAssertNil(postMethod.annotations)
        XCTAssertNil(postMethod.body)
        XCTAssertNil(postMethod.displayName)
        XCTAssertNil(postMethod.headers)
        XCTAssertNil(postMethod.responses)
        XCTAssertNil(postMethod.traitUsages)
        
    }
    
}

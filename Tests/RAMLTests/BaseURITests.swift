//
//  BaseURITests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 10.07.17.
//

import XCTest
@testable import RAML

class BaseURITests: XCTestCase {
    
    func testBaseURIWithVersionParameter() {
        let ramlString =
        """
        #%RAML 1.0
        title: Salesforce Chatter REST API
        version: v28.0
        baseUri: https://na1.salesforce.com/services/data/{version}/chatter
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let baseURI = raml.baseURI else {
            XCTFail("No BaseURI")
            return
        }
        
        XCTAssertEqual(baseURI.value, "https://na1.salesforce.com/services/data/{version}/chatter")
    }
    
    // TODO: Test BASE URI with version parameter
    
    func testBaseURIWithExplicitURIParameters() {
        let ramlString =
        """
        #%RAML 1.0
        title: Amazon S3 REST API
        baseUri: https://{bucketName}.s3.amazonaws.com
        baseUriParameters:
          bucketName:
            description: The name of the bucket
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let baseURI = raml.baseURI else {
            XCTFail("No BaseURI")
            return
        }
        
        guard let baseURIParameters = raml.baseURIParameters else {
            XCTFail("No BaseURI Parameters")
            return
        }
        
        XCTAssertEqual(baseURI.value, "https://{bucketName}.s3.amazonaws.com")
        XCTAssertEqual(baseURIParameters.count, 1)
        
        if let firstURIParameter = raml.baseURIParameters?.first {
            XCTAssertEqual(firstURIParameter.description, "The name of the bucket")
        }
    }
    
    func testBaseURIWithURIParameters() {
        let ramlString =
        """
        #%RAML 1.0
        title: GitHub API
        version: v3
        baseUri: https://api.github.com
        /user:
          description: The currently authenticated User
        /users:
          description: All users
          /{userId}:
           description: A specific user
           uriParameters:
             userId:
               description: The id of the user
               type: integer
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let usersUserIdResource = raml.resourceWith(path: "/users")?.resourceWith(path: "/{userId}") else {
            XCTFail("No /users Resource")
            return
        }
        
        XCTAssertTrue(usersUserIdResource.hasUriParameterWith(identifier: "userId"))
    }
    
    func testBaseURIWithURIParametersWithArray() {
        let ramlString =
        """
        #%RAML 1.0
        title: Serialization API
        /users:
          description: All users
          /{userIds}:
            description: A specific user
            uriParameters:
              userIds:
                description: A list of userIds
                type: array
                items:
                  type: string
                  minLength: 1
                uniqueItems: true
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let userIdsResource = raml.resourceWith(path: "/users")?.resourceWith(path: "/{userIds}") else {
            XCTFail("No Resource to /users/{userIds}")
            return
        }
        
        guard let userIdsParameter = userIdsResource.uriParameterWith(identifier: "userIds") else {
            XCTFail("No userIds Parameter")
            return
        }
        XCTAssertEqual(userIdsParameter.description, "A list of userIds")
        XCTAssertEqual(userIdsParameter.type, URIParameter.ParameterType.array)
        XCTAssertEqual(userIdsParameter.uniqueItems, true)
        guard let userIdsParameterItems = userIdsParameter.items else {
            XCTFail("No Items for userIds parameter")
            return
        }
        XCTAssertEqual(userIdsParameterItems.type, URIParameter.URIParameterItems.ParameterItemType.string)
        XCTAssertEqual(userIdsParameterItems.minLength, 1)
    }
    
    func testUriParametersWithExt() {
        let ramlString =
        """
        #%RAML 1.0
        title: API Using media type in the URL
        version: v1
        /users{ext}:
          uriParameters:
            ext:
              enum: [ .json, .xml ]
              description: Use .json to specify application/json or .xml to specify text/xml
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let usersResource = raml.resourceWith(path: "/users{ext}") else {
            XCTFail("No /users{ext} Resource")
            return
        }
        
        guard let extParameter = usersResource.uriParameterWith(identifier: "ext") else {
            XCTFail("No ext URI Parameter")
            return
        }
        XCTAssertEqual(extParameter.description, "Use .json to specify application/json or .xml to specify text/xml")
        XCTAssertEqual(extParameter.enum?.count(), 2)
        XCTAssertTrue(extParameter.enum?.contains(".json") ?? false)
        XCTAssertTrue(extParameter.enum?.contains(".xml") ?? false)
        
    }
    
    func testUriParameterWithEnumAsArray() {
        let ramlString =
        """
        #%RAML 1.0
        title: Example API
        version: v1
        traits:
          withQueryParameters:
            queryParameters:
              platform:
                enum:
                  - win
                  - mac
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let platformQueryParameter = raml.traitDefinitionWith(name: "withQueryParameters")?.queryParameterWith(identifier: "platform") else {
            XCTFail("No platform query parameter in tait definiton")
            return
        }
        XCTAssertTrue(platformQueryParameter.enum?.contains("win") ?? false)
        XCTAssertTrue(platformQueryParameter.enum?.contains("mac") ?? false)
    }
    
}


//
//  RAMLTests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 10.07.17.
//

import XCTest
@testable import RAML

class BasicRAMLFromStringTests: XCTestCase {
    
    func testMissingTitle() {
        let ramlString =
        """
        #%RAML 1.0
        foo: bar
        """
        
        do {
            let _ = try RAML(string: ramlString)
            XCTFail("Parsing should have thrown an error")
        } catch let error {
            guard let ramlError = error as? RAMLError else {
                XCTFail("Error should be an RAMLError")
                return
            }
            XCTAssertEqual(ramlError, RAMLError.ramlParsingError(.missingValueFor(key: "title")))
        }
    }
    
    func testWrongRAMLVersion() {
        let ramlString =
        """
        #%RAML 0.8
        title: Foo Bar
        """
        
        do {
            let _ = try RAML(string: ramlString)
            XCTFail("Parsing should have thrown an error")
        } catch let error {
            guard let ramlError = error as? RAMLError else {
                XCTFail("Error should be an RAMLError")
                return
            }
            XCTAssertEqual(ramlError, RAMLError.ramlParsingError(.invalidVersion))
        }
    }
    
    func testOptionals() {
        let ramlString =
        """
        #%RAML 1.0
        title: Foo Bar
        version:
        """
        
        do {
            let raml = try RAML(string: ramlString)
            XCTAssertNil(raml.version)
            XCTAssertNil(raml.description)
            XCTAssertNil(raml.baseURI)
            XCTAssertNil(raml.protocols)
            XCTAssertNil(raml.documentation)
            XCTAssertNil(raml.baseURIParameters)
            XCTAssertNil(raml.mediaTypes)
            XCTAssertNil(raml.types)
            XCTAssertNil(raml.traitDefinitions)
            // TODO: TEST resourceTypes
            XCTAssertNil(raml.annotationTypes)
            XCTAssertNil(raml.securitySchemes)
            // TODO: TEST securedBy
            // TODO: TEST uses
            XCTAssertNil(raml.resources)
        } catch {
            XCTFail("Parsing should not throw an error")
        }
    }
    
    func testParseIncludeFromString() {
        let ramlString =
        """
        #%RAML 1.0
        title: Include from String Test
        documentation:
          - title: Home
            content: !include docs/legal.markdown
        """
        
        do {
            let _ = try RAML(string: ramlString)
            XCTFail("Should fail because includes are not possible when loading from string")
        } catch {
            guard let ramlError = error as? RAMLError else {
                XCTFail("Error should be an RAMLError")
                return
            }
            XCTAssertEqual(ramlError, RAMLError.ramlParsingError(.includesNotAvailable))
        }
    }
    
    func testParseMediaType() {
        let ramlString =
        """
        #%RAML 1.0
        title: New API
        mediaType: application/json
        """
        
        do {
            let raml = try RAML(string: ramlString)
            XCTAssertEqual(raml.mediaTypes?.count, 1)
            if let firstMediaType = raml.mediaTypes?.first {
                XCTAssertEqual(firstMediaType.identifier, "application/json")
            }
        } catch {
            XCTFail("Should not fail")
        }
    }
    
    func testParseMultipleMediaTypes() {
        let ramlString =
        """
        #%RAML 1.0
        title: New API
        mediaType: [ application/xml, application/json ]
        """
        
        do {
            let raml = try RAML(string: ramlString)
            XCTAssertEqual(raml.mediaTypes?.count, 2)
            if let firstMediaType = raml.mediaTypes?.first {
                XCTAssertEqual(firstMediaType.identifier, "application/xml")
            }
        } catch {
            XCTFail("Should not fail")
        }
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
            
            guard
                let listResource = raml.resourceWith(path: "/list"),
                let getListMethod = listResource.methodWith(type: .get),
                let okResponse = getListMethod.responseWith(code: 200),
                let okResponseBody = okResponse.body
            else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(okResponseBody.type, DataType.array(ofType: .custom(type: "Person")))
            
            // inherited from default media types
            XCTAssertEqual(okResponseBody.mediaTypes?.count, 2)
            XCTAssertTrue(okResponseBody.hasMediaTypeWith(identifier: "application/json"))
            XCTAssertTrue(okResponseBody.hasMediaTypeWith(identifier: "application/xml"))
            
            guard
                let sendResource = raml.resourceWith(path: "/send"),
                let postSendMethod = sendResource.methodWith(type: .post),
                let postSendBody = postSendMethod.body,
                let jsonMediaType = postSendBody.mediaTypeWith(identifier: "application/json")
            else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(jsonMediaType.type, .custom(type: "Another"))
            
            // inheritance cancelled when mediaTypes are set explicitly
            XCTAssertEqual(postSendBody.mediaTypes?.count, 1)
            
        } catch {
            XCTFail()
        }
    }
}

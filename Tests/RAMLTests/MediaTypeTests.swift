//
//  MediaTypeTests.swift
//  RAMLTests
//
//  Created by Christoph on 11.07.17.
//

import XCTest
@testable import RAML

class MediaTypeTests: XCTestCase {
    
    func testMediaTypeApplicationJson() {
        let ramlString =
        """
        #%RAML 1.0
        title: New API
        mediaType: application/json
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let mediaTypes = raml.mediaTypes else {
            XCTFail("No Media Types")
            return
        }
        
        XCTAssertEqual(mediaTypes.count, 1)
        
        guard let mediaTypeJSON = raml.mediaTypeWith(identifier: "application/json") else {
            XCTFail("No Media Type application/json")
            return
        }
        
        XCTAssertEqual(mediaTypeJSON.identifier, "application/json")
    }
    
    func testParseMultipleMediaTypes() {
        let ramlString =
        """
        #%RAML 1.0
        title: New API
        mediaType: [ application/xml, application/json ]
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let mediaTypes = raml.mediaTypes else {
            XCTFail("No Media Types")
            return
        }
        
        XCTAssertEqual(mediaTypes.count, 2)
        XCTAssertTrue(raml.hasMediaTypeWith(identifier: "application/xml"))
        XCTAssertTrue(raml.hasMediaTypeWith(identifier: "application/json"))
    }
    
    func testParseMediaTypeInBody() {
        let ramlString =
        """
        #%RAML 1.0
        title: New API
        mediaType: [ application/json, application/xml ]
        /list:
          get:
            responses:
              200:
        /send:
          post:
            body:
              application/json:
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard
            let listResource = raml.resourceWith(path: "/list"),
            let getListMethod = listResource.methodWith(type: .get),
            let okResponse = getListMethod.responseWith(code: 200)
            else {
                XCTFail("No Resource /list GET 200")
                return
        }
        
        XCTAssertNil(okResponse.body)
        
        guard
            let sendResource = raml.resourceWith(path: "/send"),
            let postSendMethod = sendResource.methodWith(type: .post),
            let postSendBody = postSendMethod.body
            else {
                XCTFail("No Resource /send POST body")
                return
        }
        
        XCTAssertEqual(postSendBody.mediaTypes?.count, 1)
        XCTAssertTrue(postSendBody.hasMediaTypeWith(identifier: "application/json"))
    }
}

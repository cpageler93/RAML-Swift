//
//  ProtocolTests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 10.07.17.
//

import XCTest
@testable import RAML

class ProtocolTests: XCTestCase {
    
    func testValidProtocols() {
        let ramlString =
        """
        #%RAML 1.0
        title: Test
        protocols: [ HTTP, HTTPS ]
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        XCTAssertNotNil(raml.protocols)
        XCTAssertTrue(raml.hasProtocol(.http))
        XCTAssertTrue(raml.hasProtocol(.https))
    }
    
    func testParseInvalidProtocol() {
        let ramlString =
        """
        #%RAML 1.0
        title: Test
        protocols: [ HTTP, POP3 ]
        """
        
        do {
            let _ = try RAML(string: ramlString)
            XCTFail("Should fail because POP3 is invalid protocol for RAML")
        } catch let error {
            guard let ramlError = error as? RAMLError else {
                XCTFail("Error should be an RAMLError")
                return
            }
            
            XCTAssertEqual(ramlError, RAMLError.ramlParsingError(.invalidProtocol("POP3")))
        }
    }
    
}

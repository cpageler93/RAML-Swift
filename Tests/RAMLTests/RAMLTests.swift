//
//  RAMLTests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 10.07.17.
//

import XCTest
@testable import RAML

class RAMLTests: XCTestCase {
    
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
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
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
}

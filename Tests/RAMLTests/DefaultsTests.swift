//
//  DefaultsTests.swift
//  RAMLTests
//
//  Created by Christoph on 11.07.17.
//

import XCTest
@testable import RAML

class DefaultsTests: XCTestCase {
    
    func testRAMLWithTitle() {
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
        
        let ramlWithDefaults = raml.applyDefaults()
        
        XCTAssertEqual(raml.title, ramlWithDefaults.title)
        XCTAssertEqual(raml.description, ramlWithDefaults.description)
        XCTAssertEqual(raml.version, ramlWithDefaults.version)
    }
    
}

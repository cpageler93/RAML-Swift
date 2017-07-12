//
//  IncludeTests.swift
//  RAMLTests
//
//  Created by Christoph on 03.07.17.
//

import XCTest
@testable import RAML


class IncludeTests: XCTestCase {
    
    func testRootIncludes() {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "root_includes", ofType: "raml", inDirectory: "TestData/Includes") else {
            XCTFail("No Path to root_includes.raml in TestData/Includes")
            return
        }
        
        guard let raml = try? RAML(file: path) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        XCTAssertTrue(raml.hasTraitDefinitionWith(name: "chargeable"))
        XCTAssertTrue(raml.hasTraitDefinitionWith(name: "paged"))
        
        XCTAssertTrue(raml.hasResourceTypeWith(identifier: "collection"))
        XCTAssertTrue(raml.hasResourceTypeWith(identifier: "member"))
    }
    
    func testValueIncludes() {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "value_includes", ofType: "raml", inDirectory: "TestData/Includes") else {
            XCTFail("No Path to value_includes.raml in TestData/Includes")
            return
        }
        
        guard let raml = try? RAML(file: path) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        XCTAssertTrue(raml.hasTraitDefinitionWith(name: "chargeable"))
        XCTAssertTrue(raml.hasTraitDefinitionWith(name: "paged"))
        
        XCTAssertTrue(raml.hasResourceTypeWith(identifier: "collection"))
        XCTAssertTrue(raml.hasResourceTypeWith(identifier: "member"))
    }
}

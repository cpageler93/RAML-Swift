//
//  ValueIncludeTests.swift
//  RAMLTests
//
//  Created by Christoph on 03.07.17.
//

import XCTest
@testable import RAML

class ValueIncludeTests: XCTestCase {
    
    var raml: RAML!
    
    override func setUp() {
        super.setUp()
        
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "value_includes",
                                     ofType: "raml",
                                     inDirectory: "TestData/Includes") else {
                                        XCTFail()
                                        return
        }
        do {
            raml = try RAML(file: path)
        } catch {
            XCTFail()
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTraits() {
        XCTAssertTrue(raml.hasTraitDefinitionWith(name: "chargeable"))
        XCTAssertTrue(raml.hasTraitDefinitionWith(name: "paged"))
    }
    
}

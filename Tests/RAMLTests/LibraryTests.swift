//
//  LibraryTests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 12.07.17.
//

import XCTest
@testable import RAML

class LibraryTests: XCTestCase {
    
    func testLibraryIncludes() {
        
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "main", ofType: "raml", inDirectory: "TestData/Libraries") else {
            XCTFail("No Path to main.raml in TestData/Libraries")
            return
        }
        
        guard let raml = try? RAML(file: path) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
    }
}

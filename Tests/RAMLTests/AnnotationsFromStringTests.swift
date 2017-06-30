//
//  AnnotationsFromStringTests.swift
//  RAMLTests
//
//  Created by Christoph on 30.06.17.
//

import XCTest
@testable import RAML

class AnnotationsFromStringTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBaseURIWithAnnotations() {
        let ramlString =
        """
        #%RAML 1.0
        title: My API With Types
        baseUri:
          value: http://www.example.com/api
          (redirectable): true
        """
        
        do {
            let raml = try RAML(string: ramlString)
            XCTAssertEqual(raml.baseURI?.annotations.count, 1)
            if let firstAnnotation = raml.baseURI?.annotations.first {
                XCTAssertEqual(firstAnnotation.name, "redirectable")
            }
        } catch {
            XCTFail()
        }
    }
}
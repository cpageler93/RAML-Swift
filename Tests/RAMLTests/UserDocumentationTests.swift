//
//  UserDocumentationTests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 24.06.17.
//

import XCTest
@testable import RAML

class UserDocumentationTests: XCTestCase {
    
    var raml: RAML!
    
    override func setUp() {
        super.setUp()
        
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "UserDocumentation",
                                     ofType: "raml",
                                     inDirectory: "TestData") else {
            XCTFail()
            return
        }
        do {
            raml = try RAML(file: path)
        } catch {
            print("error: \(error)")
            XCTFail()
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDocumentationCount() {
        XCTAssertEqual(raml.documentation?.count, 2)
    }
}

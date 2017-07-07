//
//  DocumentationIncludeTests.swift
//  RAMLTests
//
//  Created by Christoph on 05.07.17.
//

import XCTest
@testable import RAML

class DocumentationIncludeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIncludesWithWrongPaths() {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "failure",
                                     ofType: "raml",
                                     inDirectory: "TestData/Includes/documentation") else {
                                        XCTFail()
                                        return
        }
        
        do {
            let _ = try RAML(file: path)
            XCTFail("this should fail")
        } catch let error {
            guard let ramlError = error as? RAMLError else {
                XCTFail("Should fail")
                return
            }
            switch ramlError {
            case .invalidFile(let path):
                print("is correct error.. missing file at Path: \(path)")
            default:
                XCTFail("Should be invalidFile Error")
            }
        }
    }
    
    func testIncludesSuccess() {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "success",
                                     ofType: "raml",
                                     inDirectory: "TestData/Includes/documentation") else {
                                        XCTFail()
                                        return
        }
        
        do {
            let raml = try RAML(file: path)
            guard let legalDocumentationEntry = raml.documentationEntryWith(title: "Legal") else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(legalDocumentationEntry.content, "# THIS IS NOT LEGAL")
            
        } catch {
            XCTFail("this should not fail")
        }
    }
    
}

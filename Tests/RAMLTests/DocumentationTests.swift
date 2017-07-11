//
//  DocumentationTests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 24.06.17.
//

import XCTest
@testable import RAML

class DocumentationTests: XCTestCase {
    
    func testDocumentationFromFile() {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "UserDocumentation", ofType: "raml", inDirectory: "TestData") else {
            XCTFail("No Path to UserDocumentation.raml in TestData")
            return
        }
        
        guard let raml = try? RAML(file: path) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let documentation = raml.documentation else {
            XCTFail("No documentation")
            return
        }
        
        XCTAssertEqual(documentation.count, 2)
        XCTAssertTrue(raml.hasDocumentationEntryWith(title: "Home"))
        XCTAssertTrue(raml.hasDocumentationEntryWith(title: "Legal"))
    }
    
    func testDocumentationIncludesWithWrongPaths() {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "failure", ofType: "raml", inDirectory: "TestData/Includes/documentation") else {
            XCTFail("No Path to failure.raml in TestData")
            return
        }
        
        do {
            let _ = try RAML(file: path)
            XCTFail("this should fail")
        } catch let error {
            guard let ramlError = error as? RAMLError else {
                XCTFail("Error Should be an RAMLError")
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
    
    func testDocumentationIncludesSuccess() {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "success", ofType: "raml", inDirectory: "TestData/Includes/documentation") else {
            XCTFail("No Path to success.raml in TestData")
            return
        }
        
        guard let raml = try? RAML(file: path) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let legalDocumentationEntry = raml.documentationEntryWith(title: "Legal") else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(legalDocumentationEntry.content, "# THIS IS NOT LEGAL")
    }
    
}

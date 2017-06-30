//
//  AnnotationsTests.swift
//  RAMLTests
//
//  Created by Christoph on 30.06.17.
//

import XCTest
@testable import RAML

class AnnotationsTests: XCTestCase {
    
    var raml: RAML!
    
    override func setUp() {
        super.setUp()
        
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "Annotations",
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
    
    func testAnnotationTypes() {
        XCTAssertEqual(raml.annotationTypes?.count, 6)
        
        guard let deprecatedType = raml.annotationType(withName: "deprecated") else {
            XCTFail()
            return
        }
        XCTAssertEqual(deprecatedType.type, AnnotationTypeEnum.nil)
        XCTAssertNil(deprecatedType.properties)
        
        guard let experimentalType = raml.annotationType(withName: "experimental") else {
            XCTFail()
            return
        }
        XCTAssertEqual(experimentalType.type, AnnotationTypeEnum.multiple(of: [.nil, .string]))
        XCTAssertNil(experimentalType.properties)
        
        guard let feedbackRequestedType = raml.annotationType(withName: "feedbackRequested") else {
            XCTFail()
            return
        }
        XCTAssertEqual(feedbackRequestedType.type, AnnotationTypeEnum.multiple(of: [.string, .nil]))
        XCTAssertNil(feedbackRequestedType.properties)
        
        guard let testHarnessType = raml.annotationType(withName: "testHarness") else {
            XCTFail()
            return
        }
        XCTAssertEqual(testHarnessType.type, AnnotationTypeEnum.string)
        XCTAssertNil(testHarnessType.properties)
        
        guard let badgeType = raml.annotationType(withName: "badge") else {
            XCTFail()
            return
        }
        XCTAssertEqual(badgeType.type, AnnotationTypeEnum.string)
        XCTAssertNil(badgeType.properties)
        
        guard let clearanceLevelType = raml.annotationType(withName: "clearanceLevel") else {
            XCTFail()
            return
        }
        XCTAssertEqual(clearanceLevelType.type, AnnotationTypeEnum.properties)
        XCTAssertNotNil(clearanceLevelType.properties)
        
        guard let levelProperty = clearanceLevelType.property(withName: "level") else {
            XCTFail()
            return
        }
        XCTAssertTrue(levelProperty.required ?? false)
        XCTAssertTrue(levelProperty.enum?.contains("low") ?? false)
        XCTAssertTrue(levelProperty.enum?.contains("medium") ?? false)
        XCTAssertTrue(levelProperty.enum?.contains("high") ?? false)
        
        guard let signatureProperty = clearanceLevelType.property(withName: "signature") else {
            XCTFail()
            return
        }
        XCTAssertTrue(signatureProperty.required ?? false)
        XCTAssertEqual(signatureProperty.pattern, "\\d{3}-\\w{12}")
        
    }
    
}

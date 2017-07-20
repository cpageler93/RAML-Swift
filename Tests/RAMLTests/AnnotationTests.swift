//
//  AnnotationTests.swift
//  RAMLTests
//
//  Created by Christoph on 30.06.17.
//

import XCTest
@testable import RAML

class AnnotationTests: XCTestCase {
    
    func testAnnotationsInBaseURI() {
        let ramlString =
        """
        #%RAML 1.0
        title: My API With Types
        baseUri:
          value: http://www.example.com/api
          (redirectable): true
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let baseURI = raml.baseURI else {
            XCTFail("No BaseURI")
            return
        }
        
        guard let baseURIAnnotations = baseURI.annotations else {
            XCTFail("No Annotations")
            return
        }
        XCTAssertEqual(baseURIAnnotations.count, 1)
        
        guard let redirectableAnnotation = baseURI.annotationWith(name: "redirectable") else {
            XCTFail("No `redirectable` Anotation")
            return
        }
        
        XCTAssertEqual(redirectableAnnotation.name, "redirectable")
    }
    
    func testAnnotationsFromFile() {
        
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "Annotations", ofType: "raml", inDirectory: "TestData") else {
            XCTFail("No Annotatons.raml File found in TestData")
            return
        }
        
        guard let raml = try? RAML(file: path) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let annotationTypes = raml.annotationTypes else {
            XCTFail("No Annotation Types")
            return
        }
        XCTAssertEqual(annotationTypes.count, 6)
        
        
        guard let deprecatedType = raml.annotationTypeWith(name: "deprecated") else {
            XCTFail("No `deprecated` Annotation")
            return
        }
        XCTAssertEqual(deprecatedType.type, AnnotationTypeEnum.nil)
        XCTAssertNil(deprecatedType.properties)
        
        
        guard let experimentalType = raml.annotationTypeWith(name: "experimental") else {
            XCTFail("No `experimental` Annotation")
            return
        }
        XCTAssertEqual(experimentalType.type, AnnotationTypeEnum.multiple(of: [.nil, .string]))
        XCTAssertNil(experimentalType.properties)
        
        
        guard let feedbackRequestedType = raml.annotationTypeWith(name: "feedbackRequested") else {
            XCTFail("No `feedbackRequested` Annotation")
            return
        }
        XCTAssertEqual(feedbackRequestedType.type, AnnotationTypeEnum.multiple(of: [.string, .nil]))
        XCTAssertNil(feedbackRequestedType.properties)
        
        
        guard let testHarnessType = raml.annotationTypeWith(name: "testHarness") else {
            XCTFail("No `testHarness` Annotation")
            return
        }
        XCTAssertEqual(testHarnessType.type, AnnotationTypeEnum.string)
        XCTAssertNil(testHarnessType.properties)
        
        
        guard let badgeType = raml.annotationTypeWith(name: "badge") else {
            XCTFail("No `badge` Annotation")
            return
        }
        XCTAssertNil(badgeType.type)
        XCTAssertNil(badgeType.properties)
        
        
        guard let clearanceLevelType = raml.annotationTypeWith(name: "clearanceLevel") else {
            XCTFail("No `clearanceLevel` Annotation")
            return
        }
        XCTAssertNil(clearanceLevelType.type)
        XCTAssertNotNil(clearanceLevelType.properties)
        
        
        // Level Property
        guard let levelProperty = clearanceLevelType.propertyWith(name: "level") else {
            XCTFail("No `level` Property")
            return
        }
        
        guard let levelRequired = levelProperty.required else {
            XCTFail("No `required` in `level` Property")
            return
        }
        XCTAssertTrue(levelRequired)
        
        guard let levelEnum = levelProperty.enum else {
            XCTFail("No `enum` in `level` Property")
            return
        }
        
        XCTAssertTrue(levelEnum.contains("low"))
        XCTAssertTrue(levelEnum.contains("medium"))
        XCTAssertTrue(levelEnum.contains("high"))
        
        
        // Signature Property
        guard let signatureProperty = clearanceLevelType.propertyWith(name: "signature") else {
            XCTFail("No `signature` Property")
            return
        }
        
        guard let signatureRequired = signatureProperty.required else {
            XCTFail("No `required` in `signature` Property")
            return
        }
        
        XCTAssertTrue(signatureRequired)
        XCTAssertEqual(signatureProperty.pattern, "\\\\d{3}-\\\\w{12}")
    }
    
    func testAnnotationValuesFromFile() {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "Annotations", ofType: "raml", inDirectory: "TestData") else {
            XCTFail("No Annotatons.raml File found in TestData")
            return
        }
        
        guard let raml = try? RAML(file: path) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let groupsResource = raml.resourceWith(path: "/groups") else {
            XCTFail("No /groups resource")
            return
        }
        XCTAssertTrue(groupsResource.hasAnnotationWith(name: "experimental"))
        XCTAssertTrue(groupsResource.hasAnnotationWith(name: "feedbackRequested"))
        
        guard let usersResource = raml.resourceWith(path: "/users") else {
            XCTFail("No /users Resource")
            return
        }
        XCTAssertEqual(usersResource.annotations?.count, 3)
        
        guard let testHarnessAnnotation = usersResource.annotationWith(name: "testHarness") else {
            XCTFail("No testHarness annotation")
            return
        }
        XCTAssertNil(testHarnessAnnotation.parameters)
        XCTAssertEqual(testHarnessAnnotation.singleValue, "usersTest")
        
        guard let clearanceLevelAnnotation = usersResource.annotationWith(name: "clearanceLevel") else {
            XCTFail("No clearanceLevel annotation")
            return
        }
        XCTAssertNil(clearanceLevelAnnotation.singleValue)
        XCTAssertEqual(clearanceLevelAnnotation.parameters?["level"]?.string, "high")
        XCTAssertEqual(clearanceLevelAnnotation.parameters?["signature"]?.string, "230-ghtwvfrs1itr")
    }
    
}

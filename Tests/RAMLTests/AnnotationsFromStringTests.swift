//
//  AnnotationsFromStringTests.swift
//  RAMLTests
//
//  Created by Christoph on 30.06.17.
//

import XCTest
@testable import RAML

class AnnotationsFromStringTests: XCTestCase {
    
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
            // TODO: Add Missing Value
        } catch {
            XCTFail()
        }
    }
}

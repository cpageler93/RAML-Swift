//
//  TypesFromStringTests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 25.06.17.
//

import XCTest
@testable import RAML

class TypesFromStringTests: XCTestCase {
    
    func testBasicPersonType() {
        let ramlString =
        """
        #%RAML 1.0
        title: My API With Types
        types:
          Person:
            type: object
            properties:
              name:
                required: true
                type: string
        """
        
        do {
            let raml = try RAML(string: ramlString)
            XCTAssertEqual(raml.types?.count, 1)
            if let firstType = raml.types?.first {
                XCTAssertEqual(firstType.name, "Person")
                XCTAssertEqual(firstType.type, DataType.object)
                XCTAssertEqual(firstType.properties?.count, 1)
                if let firstProperty = firstType.properties?.first {
                    XCTAssertEqual(firstProperty.required, true)
                    XCTAssertEqual(firstProperty.type, DataType.scalar(type: DataType.ScalarType.string))
                }
            }
        } catch {
            XCTFail()
        }
    }
    
    
    func testArrayPersonType() {
        let ramlString =
        """
        #%RAML 1.0
        title: My API With Types
        types:
          Person:
            type: object
            properties:
              name:
                required: true
                type: string
          Persons:
            type: Person[]
            minItems: 1
            uniqueItems: true
        """
        
        do {
            let raml = try RAML(string: ramlString)
            XCTAssertEqual(raml.types?.count, 2)
            
            var foundArrayType = false
            
            for type in raml.types ?? [] {
                if type.name == "Persons" {
                    foundArrayType = true
                    XCTAssertEqual(type.type, DataType.array(ofType: DataType.custom(type: "Person")))
                    XCTAssertNil(type.properties)
                }
            }
            
            XCTAssertTrue(foundArrayType)
        } catch {
            XCTFail()
        }
    }
}

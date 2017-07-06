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
              optionalTest?: string
              optionalTest2??: number
        """
        
        do {
            let raml = try RAML(string: ramlString)
            XCTAssertEqual(raml.types?.count, 1)
            if let personType = raml.typeWith(name: "Person") {
                XCTAssertEqual(personType.name, "Person")
                XCTAssertEqual(personType.type, DataType.object)
                XCTAssertEqual(personType.properties?.count, 3)
                
                if let nameProperty = personType.propertyWith(name: "name") {
                    XCTAssertEqual(nameProperty.required, true)
                    XCTAssertEqual(nameProperty.type, DataType.scalar(type: DataType.ScalarType.string))
                } else {
                    XCTFail()
                }
                
                if let optionalTestProperty = personType.propertyWith(name: "optionalTest") {
                    XCTAssertEqual(optionalTestProperty.required, false)
                    XCTAssertEqual(optionalTestProperty.type, DataType.scalar(type: DataType.ScalarType.string))
                } else {
                    XCTFail()
                }
                
                if let optionalTest2Property = personType.propertyWith(name: "optionalTest2?") {
                    XCTAssertEqual(optionalTest2Property.required, false)
                    XCTAssertEqual(optionalTest2Property.type, DataType.scalar(type: DataType.ScalarType.number))
                } else {
                    XCTFail()
                }
            } else {
                XCTFail()
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
            XCTFail("Should not fail")
        }
    }
    
    func testPropertyTypeEnum() {
        let ramlString =
        """
        #%RAML 1.0
        title: My API with Types
        mediaType: application/json
        types:
          Person:
            type: object
            properties:
              firstname: string
              lastname:  string
              title?:    string
          Admin:
            type: Person
            properties:
              clearanceLevel:
                enum: [ low, high ]
        """
        
        do {
            let raml = try RAML(string: ramlString)
            
            guard let adminType = raml.typeWith(name: "Admin") else {
                XCTFail()
                return
            }
            
            guard let clearanceLevelProperty = adminType.propertyWith(name: "clearanceLevel") else {
                XCTFail()
                return
            }
            
            guard let clearanceLevelPropertyEnum = clearanceLevelProperty.enum else {
                XCTFail()
                return
            }
            XCTAssertTrue(clearanceLevelPropertyEnum.contains("low"))
            XCTAssertTrue(clearanceLevelPropertyEnum.contains("high"))
            
        } catch {
            XCTFail("This should not fail")
        }
    }
}

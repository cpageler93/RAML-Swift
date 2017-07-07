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
    
    func testTypeDefaultTypeExplicit() {
        let ramlStringExplicit =
        """
        #%RAML 1.0
        title: My API with Types
        types:
          Person:
            type: object
            properties:
        """
        
        do {
            let ramlExplicit = try RAML(string: ramlStringExplicit)
            guard let personType = ramlExplicit.typeWith(name: "Person") else {
                XCTFail("This should not fail")
                return
            }
            XCTAssertEqual(personType.type, .object)
        } catch {
            XCTFail("This should not fail")
        }
    }
    
    func testTypeDefaultTypeImplicit() {
        
        let ramlStringImplicit =
        """
        #%RAML 1.0
        title: My API with Types
        types:
          Person:
            properties:
        """
        
        do {
            let ramlImplicit = try RAML(string: ramlStringImplicit)
            guard let personType = ramlImplicit.typeWith(name: "Person") else {
                XCTFail("This should not fail")
                return
            }
            XCTAssertEqual(personType.type, .object)
        } catch {
            XCTFail("This should not fail")
        }
        
    }
    
    func testTypeDefaultTypeImplicitString() {
        
        let ramlStringImplicitString =
        """
        #%RAML 1.0
        title: My API with Types
        types:
          Person:
        """
        
        do {
            let ramlImplicitString = try RAML(string: ramlStringImplicitString)
            guard let personType = ramlImplicitString.typeWith(name: "Person") else {
                XCTFail("This should not fail")
                return
            }
            XCTAssertEqual(personType.type, .scalar(type: .string))
        } catch {
            XCTFail("This should not fail")
        }
    }
    
    func testTypeDefaultTypeImplicitStringInProperty() {
        
        let ramlStringImplicitStringInProperty =
        """
        #%RAML 1.0
        title: My API with Types
        types:
          Person:
            properties:
              name:
        """
        
        do {
            let ramlImplicitStringInProperty = try RAML(string: ramlStringImplicitStringInProperty)
            guard let personType = ramlImplicitStringInProperty.typeWith(name: "Person") else {
                XCTFail("This should not fail")
                return
            }
            XCTAssertEqual(personType.type, .object)
            
            guard let nameProperty = personType.propertyWith(name: "name") else {
                XCTFail("This should not fail")
                return
            }
            
            XCTAssertEqual(nameProperty.type, .scalar(type: .string))
            
        } catch {
            XCTFail("This should not fail")
        }
    }
    
    func testTypeDefaultTypeForBodyMediaTypes() {
        let ramlString =
        """
        #%RAML 1.0
        title: My API with Types
        /send:
          post:
            body:
              application/json:
        """
        
        do {
            let raml = try RAML(string: ramlString)
            
            guard
                let sendResource = raml.resourceWith(path: "/send"),
                let postSend = sendResource.methodWith(type: .post),
                let sendBody = postSend.body,
                let jsonMediaType = sendBody.mediaTypeWith(identifier: "application/json")
            else {
                XCTFail("This should not fail")
                return
            }
            
            XCTAssertEqual(sendBody.type, DataType.any)
            XCTAssertEqual(jsonMediaType.type, DataType.any)
        } catch {
            XCTFail("This should not fail")
        }
    }
    
    // https://github.com/raml-org/raml-spec/blob/master/versions/raml-10/raml-10.md/#type-expressions
    func testTypeExpressions() {
        let ramlString =
        """
        #%RAML 1.0
        title: My API with Types
        types:
          Person:
            type: object
            properties:
          Persons: Person[]
          Strings: string[]
          BiDimensionalStrings: string[][]
          StringOrPerson: string | Person
          ArrayOfStringsOrPersons: (string | Person)[]
        """
        
        do {
            let raml = try RAML(string: ramlString)
            guard
                let personType = raml.typeWith(name: "Person"),
                let personsType = raml.typeWith(name: "Persons"),
                let stringsType = raml.typeWith(name: "Strings"),
                let biDimensionalStringsType = raml.typeWith(name: "BiDimensionalStrings"),
                let stringOrPerson = raml.typeWith(name: "StringOrPerson"),
                let arrayOfstringsOrPersons = raml.typeWith(name: "ArrayOfStringsOrPersons")
            else {
                XCTFail("This should not fail")
                return
            }
            
            XCTAssertEqual(personType.type, .object)
            XCTAssertEqual(personsType.type, .array(ofType: .custom(type: "Person")))
            XCTAssertEqual(stringsType.type, .array(ofType: .scalar(type: .string)))
            XCTAssertEqual(biDimensionalStringsType.type, .array(ofType: .array(ofType: .scalar(type: .string))))
            XCTAssertEqual(stringOrPerson.type, .union(types: [.scalar(type: .string), .custom(type: "Person")]))
            XCTAssertEqual(arrayOfstringsOrPersons.type, .array(ofType: .union(types: [.scalar(type: .string), .custom(type: "Person")])))
            
        } catch {
            XCTFail("This should not fail")
        }
    }
}

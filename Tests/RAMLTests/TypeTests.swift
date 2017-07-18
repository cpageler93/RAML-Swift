//
//  TypeTests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 25.06.17.
//

import XCTest
@testable import RAML

class TypeTests: XCTestCase {
    
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
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let types = raml.types else {
            XCTFail("No Types")
            return
        }
        
        XCTAssertEqual(types.count, 1)
        
        guard let personType = raml.typeWith(name: "Person") else {
            XCTFail("No Person Type")
            return
        }
        
        XCTAssertEqual(personType.name, "Person")
        XCTAssertEqual(personType.type, DataType.object)
        
        guard let properties = personType.properties else {
            XCTFail("No Properties")
            return
        }
        XCTAssertEqual(properties.count, 3)
        
        guard let nameProperty = personType.propertyWith(name: "name") else {
            XCTFail("No Name Property")
            return
        }
        XCTAssertEqual(nameProperty.required, true)
        XCTAssertEqual(nameProperty.type, DataType.scalar(type: DataType.ScalarType.string))
        
        
        guard let optionalTestProperty = personType.propertyWith(name: "optionalTest?") else {
            XCTFail("No Optional Test Property")
            return
        }
        XCTAssertEqual(optionalTestProperty.type, DataType.scalar(type: DataType.ScalarType.string))
        XCTAssertNil(optionalTestProperty.required)
        
        
        guard let optionalTest2Property = personType.propertyWith(name: "optionalTest2??") else {
            XCTFail("No Optional Test 2 Property")
            return
        }
        XCTAssertNil(optionalTest2Property.required)
        XCTAssertEqual(optionalTest2Property.type, DataType.scalar(type: DataType.ScalarType.number))
    }
    
    
    func testArrayPersonType() {
        let ramlString =
        """
        #%RAML 1.0
        title: My API With Types
        types:
          Persons:
            type: Person[]
            minItems: 1
            uniqueItems: true
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let types = raml.types else {
            XCTFail("No Types")
            return
        }
        XCTAssertEqual(types.count, 1)
        
        guard let personsType = raml.typeWith(name: "Persons") else {
            XCTFail("No Persons Type")
            return
        }
        
        XCTAssertEqual(personsType.type, DataType.array(ofType: DataType.custom(type: "Person")))
        // TODO: Test minItems
        // TODO: Test uniqueItems
        XCTAssertNil(personsType.properties)
    }
    
    func testPropertyTypeEnum() {
        let ramlString =
        """
        #%RAML 1.0
        title: My API with Types
        types:
          Admin:
            type: object
            properties:
              clearanceLevel:
                enum: [ low, high ]
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let adminType = raml.typeWith(name: "Admin") else {
            XCTFail("No Admin Type")
            return
        }
        XCTAssertEqual(adminType.type, .object)
        
        guard let clearanceLevelProperty = adminType.propertyWith(name: "clearanceLevel") else {
            XCTFail("No ClearanceLevel Property")
            return
        }
        
        guard let clearanceLevelPropertyEnum = clearanceLevelProperty.enum else {
            XCTFail("No enum in ClearanceLevel Property")
            return
        }
        
        XCTAssertTrue(clearanceLevelPropertyEnum.contains("low"))
        XCTAssertTrue(clearanceLevelPropertyEnum.contains("high"))
    }
    
    func testTypeDefaultTypeExplicit() {
        let ramlString =
        """
        #%RAML 1.0
        title: My API with Types
        types:
          Person:
            type: object
            properties:
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let personType = raml.typeWith(name: "Person") else {
            XCTFail("No Person Type")
            return
        }
        XCTAssertEqual(personType.type, .object)
        XCTAssertNotNil(personType.properties)
    }
    
    func testTypeDefaultTypeImplicit() {
        
        let ramlString =
        """
        #%RAML 1.0
        title: My API with Types
        types:
          Person:
            properties:
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let personType = raml.typeWith(name: "Person") else {
            XCTFail("No Person Type")
            return
        }
        
        XCTAssertNil(personType.type)
        XCTAssertNotNil(personType.properties)
        
    }
    
    func testTypeDefaultTypeImplicitString() {
        
        let ramlString =
        """
        #%RAML 1.0
        title: My API with Types
        types:
          Person:
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let personType = raml.typeWith(name: "Person") else {
            XCTFail("No Person Type")
            return
        }
        
        XCTAssertNil(personType.type)
    }
    
    func testTypeDefaultTypeImplicitStringInProperty() {
        
        let ramlString =
        """
        #%RAML 1.0
        title: My API with Types
        types:
          Person:
            properties:
              name:
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let personType = raml.typeWith(name: "Person") else {
            XCTFail("No Person Type")
            return
        }
        XCTAssertNil(personType.type)
        
        guard let nameProperty = personType.propertyWith(name: "name") else {
            XCTFail("No Name Property")
            return
        }
        
        XCTAssertNil(nameProperty.type)
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
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard
            let sendResource = raml.resourceWith(path: "/send"),
            let postSend = sendResource.methodWith(type: .post),
            let sendBody = postSend.body,
            let jsonMediaType = sendBody.mediaTypeWith(identifier: "application/json")
            else {
                XCTFail("This Resource for /send POST body application/json")
                return
        }
        
        XCTAssertNil(sendBody.type)
        XCTAssertNil(jsonMediaType.type)
    }
    
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
        
        guard
            let raml = try? RAML(string: ramlString),
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
    }
    
    func testDiscriminator() {
        let ramlString =
        """
        #%RAML 1.0
        title: My API With Types
        types:
          Person:
            type: object
            discriminator: kind
            properties:
              name: string
              kind: string
          Employee:
            type: Person
            discriminatorValue: employee
            properties:
              employeeId: string
          User:
            type: Person
            discriminatorValue: user
            properties:
              userId: string
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let personType = raml.typeWith(name: "Person") else {
            XCTFail("No Person Type")
            return
        }
        XCTAssertEqual(personType.type, DataType.object)
        XCTAssertEqual(personType.discriminator, "kind")
        XCTAssertEqual(personType.properties?.count, 2)
        
        guard let employeeType = raml.typeWith(name: "Employee") else {
            XCTFail("No Employee Type")
            return
        }
        XCTAssertEqual(employeeType.type, DataType.custom(type: "Person"))
        XCTAssertEqual(employeeType.discriminatorValue, "employee")
        XCTAssertEqual(employeeType.properties?.count, 1)
        
        guard let userType = raml.typeWith(name: "User") else {
            XCTFail("No User Type")
            return
        }
        XCTAssertEqual(userType.type, DataType.custom(type: "Person"))
        XCTAssertEqual(userType.discriminatorValue, "user")
        XCTAssertEqual(userType.properties?.count, 1)
        
    }
    
    func testArrayType() {
        let ramlString =
        """
        #%RAML 1.0
        title: My API With Types
        types:
          Email:
            type: object
            properties:
              subject: string
              body: string
          Emails:
            type: Email[]
            minItems: 1
            uniqueItems: true
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let emailType = raml.typeWith(name: "Email") else {
            XCTFail("No Email Type")
            return
        }
        XCTAssertEqual(emailType.type, DataType.object)
        XCTAssertEqual(emailType.properties?.count, 2)
        
        guard let emailsType = raml.typeWith(name: "Emails") else {
            XCTFail("No Emails Type")
            return
        }
        XCTAssertEqual(emailsType.type, DataType.array(ofType: DataType.custom(type: "Email")))
        XCTAssertEqual(emailsType.minItems, 1)
        XCTAssertEqual(emailsType.uniqueItems, true)
    }
    
    func testMultipleInheritance() {
        let ramlString =
        """
        #%RAML 1.0
        title: My API With Types
        types:
          Person:
            type: object
            properties:
              name: string
          Employee:
            type: object
            properties:
              employeeNr: integer
          Teacher:
            type: [ Person, Employee ]
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let teacherType = raml.typeWith(name: "Teacher") else {
            XCTFail("No Teacher Type")
            return
        }
        
        XCTAssertEqual(teacherType.type, DataType.union(types: [DataType.custom(type: "Person"), DataType.custom(type: "Employee")]))
    }
}

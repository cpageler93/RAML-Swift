//
//  RAMLTests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 10.07.17.
//

import XCTest
@testable import RAML

class RAMLTests: XCTestCase {
    
    func testMissingTitle() {
        let ramlString =
        """
        #%RAML 1.0
        foo: bar
        """
        
        do {
            let _ = try RAML(string: ramlString)
            XCTFail("Parsing should have thrown an error")
        } catch let error {
            guard let ramlError = error as? RAMLError else {
                XCTFail("Error should be an RAMLError")
                return
            }
            XCTAssertEqual(ramlError, RAMLError.ramlParsingError(.missingValueFor(key: "title")))
        }
    }
    
    func testWrongRAMLVersion() {
        let ramlString =
        """
        #%RAML 0.8
        title: Foo Bar
        """
        
        do {
            let _ = try RAML(string: ramlString)
            XCTFail("Parsing should have thrown an error")
        } catch let error {
            guard let ramlError = error as? RAMLError else {
                XCTFail("Error should be an RAMLError")
                return
            }
            XCTAssertEqual(ramlError, RAMLError.ramlParsingError(.invalidVersion))
        }
    }
    
    func testOptionals() {
        let ramlString =
        """
        #%RAML 1.0
        title: Foo Bar
        version:
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        XCTAssertNil(raml.version)
        XCTAssertNil(raml.description)
        XCTAssertNil(raml.baseURI)
        XCTAssertNil(raml.protocols)
        XCTAssertNil(raml.documentation)
        XCTAssertNil(raml.baseURIParameters)
        XCTAssertNil(raml.mediaTypes)
        XCTAssertNil(raml.types)
        XCTAssertNil(raml.traitDefinitions)
        XCTAssertNil(raml.resourceTypes)
        XCTAssertNil(raml.annotationTypes)
        XCTAssertNil(raml.securitySchemes)
        XCTAssertNil(raml.securedBy)
        XCTAssertNil(raml.uses)
        XCTAssertNil(raml.resources)
    }
    
    func testParseIncludeFromString() {
        let ramlString =
        """
        #%RAML 1.0
        title: Include from String Test
        documentation:
          - title: Home
            content: !include docs/legal.markdown
        """
        
        do {
            let _ = try RAML(string: ramlString)
            XCTFail("Should fail because includes are not possible when loading from string")
        } catch {
            guard let ramlError = error as? RAMLError else {
                XCTFail("Error should be an RAMLError")
                return
            }
            XCTAssertEqual(ramlError, RAMLError.ramlParsingError(.includesNotAvailable))
        }
    }
    
    func testRamlWithComments1() {
        let ramlString =
        """
        #%RAML 1.0
        title: My API With Types
        types:
          Person:
            type: object
            discriminator: kind # refers to the `kind` property of object `Person`
            properties:
              kind: string # contains name of the kind of a `Person` instance
              name: string
          Employee: # kind can equal `Employee`; default value for `discriminatorValue`
            type: Person
            properties:
              employeeId: integer
          User: # kind can equal `User`; default value for `discriminatorValue`
            type: Person
            properties:
              userId: integer
        """
        
        guard let _ = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
    }
    
    func testRamlWithComments2() {
        let ramlString =
        """
        #%RAML 1.0
        title: My API With Types
        types:
          Person:
            # default type is `object`, no need to explicitly define it
            properties:
        """
        
        guard let _ = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
    }
    
    func testRamlWithComments3() {
        let ramlString =
        """
        #%RAML 1.0
        title: API with Examples

        types:
          User:
            type: object
            properties:
              name: string
              lastname: string
            example:
              name: Bob
              lastname: Marley
          Org:
            type: object
            properties:
              name: string
              address?: string
              value?: string
        /organization:
          post:
            headers:
              UserID:
                description: the identifier for the user who posts a new organization
                type: string
                example: SWED-123 # single scalar example
            body:
              application/json:
                type: Org
                example: # single request body example
                  value: # needs to be declared since instance contains a 'value' property
                    name: Doe Enterprise
                    value: Silver
          get:
            description: Returns an organization entity.
            responses:
              201:
                body:
                  application/json:
                    type: Org
                    examples:
                      acme:
                        name: Acme
                      softwareCorp:
                        value: # validate against the available facets for the map value of an example
                          name: Software Corp
                          address: 35 Central Street
                          value: Gold # validate against an instance of the `value` property
        """
        
        guard let _ = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
    }
    
    func testDecimalsInRaml() {
        let ramlString =
        """
        #%RAML 1.0
        title: Illustrate query parameter variations
        /locations:
          get:
            queryString:
              type: [paging,  lat-long | loc ]
              examples:
                second:
                  value:
                    start: 2
                    page-size: 20
                    location: 1,2
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let example = raml.resourceWith(path: "/locations")?.methodWith(type: .get)?.queryString?.exampleWith(identifier: "second") else {
            XCTFail("No Example")
            return
        }
        
        XCTAssertEqual(example.value?["location"]?.string, "1,2")
    }
}

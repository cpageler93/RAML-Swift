//
//  ExampleTests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 20.07.17.
//

import XCTest
@testable import RAML

class ExampleTests: XCTestCase {
    
    func testTypeExamples() {
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
            examples:
              Foo:
                displayName: Foo Example
                value:
                  name: Some Name
                  address: My Address
                  value: Some Value
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let userType = raml.typeWith(name: "User") else {
            XCTFail("No User Type")
            return
        }
        
        guard let userExample = userType.examples?.first else {
            XCTFail("No User Example")
            return
        }
        XCTAssertEqual(userExample.value?["name"]?.string ?? "", "Bob")
        XCTAssertEqual(userExample.value?["lastname"]?.string ?? "", "Marley")
        
        guard let orgType = raml.typeWith(name: "Org") else {
            XCTFail("No Org Type")
            return
        }
        
        guard let orgExample = orgType.examples?.first else {
            XCTFail("No Org Example")
            return
        }
        XCTAssertEqual(orgExample.displayName, "Foo Example")
        XCTAssertNil(orgExample.annotations)
        XCTAssertNil(orgExample.strict)
        XCTAssertNil(orgExample.description)
        
        XCTAssertEqual(orgExample.value?["name"]?.string, "Some Name")
        
    }
    
    func testResourceExamples() {
        let ramlString =
        """
        #%RAML 1.0
        title: API with Examples

        /organization:
          post:
            headers:
              UserID:
                description: the identifier for the user who posts a new organization
                type: string
                example: SWED-123
            body:
              application/json:
                type: Org
                example:
                  (exampleAnnotation): Value for Example annotation
                  value:
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
                        value:
                          name: Software Corp
                          address: 35 Central Street
                          value: Gold
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let organizationPost = raml.resourceWith(path: "/organization")?.methodWith(type: .post) else {
            XCTFail("No /organization POST Resource")
            return
        }
        
        guard let userIdHeader = organizationPost.headerWith(key: "UserID") else {
            XCTFail("No UserID Header")
            return
        }
        XCTAssertEqual(userIdHeader.example, "SWED-123")
        
        guard let appJson = organizationPost.body?.mediaTypeWith(identifier: "application/json") else {
            XCTFail("No application/json in body for Organization POST")
            return
        }
        
        guard let appJsonExample = appJson.examples?.first else {
            XCTFail("No Example for application/json")
            return
        }
        
        XCTAssertEqual(appJsonExample.annotations?.count, 1)
        XCTAssertEqual(appJsonExample.value?["name"], "Doe Enterprise")
        XCTAssertEqual(appJsonExample.value?["value"], "Silver")
        
//      get:
//        description: Returns an organization entity.
//        responses:
//          201:
//            body:
//              application/json:
//                type: Org
//                examples:
//                  acme:
//                    name: Acme
//                  softwareCorp:
//                    value:
//                      name: Software Corp
//                      address: 35 Central Street
//                      value: Gold
        guard let organizationGet201BodyAppJson =
            raml.resourceWith(path: "/organization")?
            .methodWith(type: .get)?
            .responseWith(code: 201)?
            .body?
            .mediaTypeWith(identifier: "application/json")
        else {
            XCTFail("No application/json in Body for 201 Response in /organization Get Resource")
            return
        }
        XCTAssertEqual(organizationGet201BodyAppJson.examples?.count ?? 0, 2)
        guard let acmeExample = organizationGet201BodyAppJson.exampleWith(identifier: "acme") else {
            XCTFail("No acme Example")
            return
        }
        XCTAssertEqual(acmeExample.value?["name"]?.string ?? "", "Acme")
    }
    
    func testExampleWithArray() {
        let ramlString =
        """
        #%RAML 1.0
        title: API with Examples

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
            example:
              - subject: My Email 1
                body: This is the text for email 1.
              - subject: My Email 2
                body: This is the text for email 2.
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let emailsType = raml.typeWith(name: "Emails") else {
            XCTFail("No Emails Type")
            return
        }
        XCTAssertEqual(emailsType.examples?.count ?? 0, 2)
        
        guard let example1 = emailsType.exampleWith(identifier: "Example 1") else {
            XCTFail("No Example 1")
            return
        }
        XCTAssertEqual(example1.value?["subject"]?.string, "My Email 1")
        XCTAssertEqual(example1.value?["body"]?.string, "This is the text for email 1.")
    }
    
}

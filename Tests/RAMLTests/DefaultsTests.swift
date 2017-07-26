//
//  DefaultsTests.swift
//  RAMLTests
//
//  Created by Christoph on 11.07.17.
//

import XCTest
@testable import RAML

class DefaultsTests: XCTestCase {
    
    func testMinimalRAMLDefaults() {
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
        
        let ramlWithDefaults = raml.applyDefaults()
        
        XCTAssertEqual(raml.title, ramlWithDefaults.title)
        XCTAssertEqual(raml.description, ramlWithDefaults.description)
        XCTAssertEqual(raml.version, ramlWithDefaults.version)
        XCTAssertNil(ramlWithDefaults.baseURI)
        XCTAssertNil(ramlWithDefaults.baseURIParameters)
        XCTAssertNotNil(ramlWithDefaults.protocols) // has defaults
        XCTAssertNotNil(ramlWithDefaults.mediaTypes) // has defaults
        XCTAssertNil(ramlWithDefaults.documentation)
        XCTAssertNil(ramlWithDefaults.types)
        XCTAssertNil(ramlWithDefaults.traitDefinitions)
        XCTAssertNil(ramlWithDefaults.resourceTypes)
        XCTAssertNil(ramlWithDefaults.annotationTypes)
        XCTAssertNil(ramlWithDefaults.securitySchemes)
        XCTAssertNil(ramlWithDefaults.securedBy)
        XCTAssertNil(ramlWithDefaults.uses)
        XCTAssertNil(ramlWithDefaults.resources)
        XCTAssertNil(ramlWithDefaults.annotations)
        
        // Test Default Protocols
        XCTAssertFalse(raml.hasProtocol(.http))
        XCTAssertFalse(raml.hasProtocol(.https))
        XCTAssertTrue(ramlWithDefaults.hasProtocol(.http))
        XCTAssertTrue(ramlWithDefaults.hasProtocol(.https))
        
        // Test Default Media Types
        XCTAssertFalse(raml.hasMediaTypeWith(identifier: "application/json"))
        XCTAssertTrue(ramlWithDefaults.hasMediaTypeWith(identifier: "application/json"))
    }
    
    func testTypeDefaults() {
        let ramlString =
        """
        #%RAML 1.0
        title: Foo Bar
        types:
          Person:
            # default type is `object`, no need to explicitly define it
            properties:
              name: # no type or schema necessary since the default type is `string`
          Persons:
            type: Person[]
          UserPicture:
            type: file
            fileTypes: ['image/jpeg', 'image/png']
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        let ramlWithDefaults = raml.applyDefaults()
        
        
        
        // RAW
        guard let rawPersonType = raml.typeWith(name: "Person") else {
            XCTFail("No Person Type")
            return
        }
        XCTAssertNil(rawPersonType.type)
        XCTAssertNil(rawPersonType.additionalProperties)
        XCTAssertNil(rawPersonType.discriminatorValue)
        guard let rawPersonProp = rawPersonType.propertyWith(name: "name") else {
            XCTFail("No name property")
            return
        }
        XCTAssertNil(rawPersonProp.type)
        XCTAssertNil(rawPersonProp.required)
        XCTAssertNil(rawPersonProp.restrictions)
        
        // WITH DEFAULTS
        guard let defaultsPersonType = ramlWithDefaults.typeWith(name: "Person") else {
            XCTFail("No Person Type")
            return
        }
        XCTAssertEqual(defaultsPersonType.type, DataType.object)
        XCTAssertEqual(defaultsPersonType.additionalProperties, true)
        XCTAssertEqual(defaultsPersonType.discriminatorValue, "person")
        
        guard let defaultsPersonProp = defaultsPersonType.propertyWith(name: "name") else {
            XCTFail("No name property")
            return
        }
        XCTAssertEqual(defaultsPersonProp.type, DataType.scalar(type: .string))
        XCTAssertEqual(defaultsPersonProp.required, true)
        
        guard let defaultsPersonPropRestrictions = defaultsPersonProp.restrictions as? StringRestrictions else {
            XCTFail("No String Restrictions")
            return
        }
        XCTAssertEqual(defaultsPersonPropRestrictions.minLength, 0)
        XCTAssertEqual(defaultsPersonPropRestrictions.maxLength, 2147483647)
        
        
        
        
        // RAW PERSONS
        guard let rawPersonsType = raml.typeWith(name: "Persons") else {
            XCTFail("No Persons Type")
            return
        }
        XCTAssertNil(rawPersonsType.minItems)
        XCTAssertNil(rawPersonsType.maxItems)
        
        // PERSONS WITH DEFAULTS
        guard let defaultsPersonsType = ramlWithDefaults.typeWith(name: "Persons") else {
            XCTFail("No Persons Type")
            return
        }
        XCTAssertEqual(defaultsPersonsType.minItems, 0)
        XCTAssertEqual(defaultsPersonsType.maxItems, 2147483647)
        
        
        // RAW USER PICTURE
        guard let rawUserPicture = raml.typeWith(name: "UserPicture") else {
            XCTFail("No User Picture")
            return
        }
        guard let rawUserPictureRestrictions = rawUserPicture.restrictions as? FileRestrictions else {
            XCTFail("No Restrictions for User Picture")
            return
        }
        XCTAssertNil(rawUserPictureRestrictions.minLength)
        XCTAssertNil(rawUserPictureRestrictions.maxLength)
        XCTAssertNotNil(rawUserPictureRestrictions.fileTypes)
        
        // USER PICTURE WITH DEFAULTS
        guard let defaultsUserPicture = ramlWithDefaults.typeWith(name: "UserPicture") else {
            XCTFail("No User Picture")
            return
        }
        
        guard let defaultsUserPictureRestrictions = defaultsUserPicture.restrictions as? FileRestrictions else {
            XCTFail("No Restrictions for User Picture")
            return
        }
        XCTAssertEqual(defaultsUserPictureRestrictions.minLength, 0)
        XCTAssertEqual(defaultsUserPictureRestrictions.maxLength, 2147483647)
    }
    
    func testMediaTypeDefaults() {
        let ramlString =
        """
        #%RAML 1.0
        title: New API
        mediaType: [ application/json, application/xml ]
        types:
          Person:
          Another:
        /list:
          get:
            responses:
              200:
                body: Person[]
        /send:
          post:
            body:
              application/json:
                type: Another
        /foo:
          post:
            body:
              application/json:
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        let ramlWithDefaults = raml.applyDefaults()
        
        // LIST
        guard let rawListGet200Body = raml
            .resourceWith(path: "/list")?
            .methodWith(type: .get)?
            .responseWith(code: 200)?
            .body else {
            XCTFail("No GET /list 200 body")
            return
        }
        XCTAssertFalse(rawListGet200Body.hasMediaTypeWith(identifier: "application/json"))
        XCTAssertFalse(rawListGet200Body.hasMediaTypeWith(identifier: "application/xml"))
        XCTAssertEqual(rawListGet200Body.type, DataType.array(ofType: DataType.custom(type: "Person")))
        
        guard let defaultsListGet200Body = ramlWithDefaults
            .resourceWith(path: "/list")?
            .methodWith(type: .get)?
            .responseWith(code: 200)?
            .body else {
                XCTFail("No /list")
                return
        }
        XCTAssertTrue(defaultsListGet200Body.hasMediaTypeWith(identifier: "application/json"))
        XCTAssertTrue(defaultsListGet200Body.hasMediaTypeWith(identifier: "application/xml"))
        XCTAssertEqual(defaultsListGet200Body.mediaTypeWith(identifier: "application/json")?.type, DataType.array(ofType: DataType.custom(type: "Person")))
        XCTAssertEqual(defaultsListGet200Body.mediaTypeWith(identifier: "application/xml")?.type, DataType.array(ofType: DataType.custom(type: "Person")))
        
        
        // SEND
        guard let rawSendPostBody = raml
            .resourceWith(path: "/send")?
            .methodWith(type: .post)?
            .body else {
                XCTFail("No SEND /post body")
                return
        }
        XCTAssertTrue(rawSendPostBody.hasMediaTypeWith(identifier: "application/json"))
        XCTAssertFalse(rawSendPostBody.hasMediaTypeWith(identifier: "application/xml"))
        
        guard let defaultsSendPostBody = ramlWithDefaults
            .resourceWith(path: "/send")?
            .methodWith(type: .post)?
            .body else {
                XCTFail("No SEND /post body")
                return
        }
        XCTAssertTrue(defaultsSendPostBody.hasMediaTypeWith(identifier: "application/json"))
        XCTAssertFalse(defaultsSendPostBody.hasMediaTypeWith(identifier: "application/xml"))
        XCTAssertEqual(defaultsSendPostBody.mediaTypeWith(identifier: "application/json")?.type, DataType.custom(type: "Another"))
        
        guard let fooPostBody = ramlWithDefaults
            .resourceWith(path: "/foo")?
            .methodWith(type: .post)?
            .body else {
            XCTFail("No POST /foo body")
            return
        }
        
        XCTAssertEqual(fooPostBody.type, DataType.any)
        XCTAssertEqual(fooPostBody.mediaTypeWith(identifier: "application/json")?.type, DataType.any)
    }
    
    func testDefaultAnnotationTypes() {
        let ramlString =
        """
        #%RAML 1.0
        title: Testing annotations
        mediaType: application/json
        annotationTypes:
          testHarness:
        /users:
          (testHarness): usersTest
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let testHarness = raml.annotationTypeWith(name: "testHarness") else {
            XCTFail("No annotation Type testHarness")
            return
        }
        
        XCTAssertNil(testHarness.type)
        XCTAssertNil(testHarness.displayName)
        
        let ramlWithDefaults = raml.applyDefaults()
        guard let testHarnessFromDefaults = ramlWithDefaults.annotationTypeWith(name: "testHarness") else {
            XCTFail("No annotation Type testHarness")
            return
        }
        XCTAssertEqual(testHarnessFromDefaults.type, AnnotationTypeEnum.string)
        XCTAssertEqual(testHarnessFromDefaults.displayName, "testHarness")
    }
    
    // TODO: default annotation types: string
    // TODO: display name = name of annotation
    
    func testResourceMethods() {
        let ramlString =
        """
        #%RAML 1.0
        title: GitHub API
        version: v3
        baseUri: https://api.github.com
        mediaType: [ application/json ]
        /gists:
          displayName: Gists
          /public:
            displayName: Public Gists
        /foo:
          displayName: Foo
          /bar:
            displayName: Bar
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        XCTAssertNil(raml.resourceWith(path: "/gists")?.methods)
        XCTAssertNil(raml.resourceWith(path: "/gists")?.resourceWith(path: "/public")?.methods)
        
        let ramlWithDefaults = raml.applyDefaults()
        XCTAssertEqual(ramlWithDefaults.resourceWith(path: "/gists")?.methods?.count ?? 0, 1)
        XCTAssertEqual(ramlWithDefaults.resourceWith(path: "/gists")?.resourceWith(path: "/public")?.methods?.count ?? 0, 1)
        
        guard let gistsGet = ramlWithDefaults.resourceWith(path: "/gists")?.methodWith(type: .get) else {
            XCTFail("No GET /gists")
            return
        }
        
        XCTAssertTrue(gistsGet.responseWith(code: 200)?.body?.hasMediaTypeWith(identifier: "application/json") ?? false)
    }
    
    func testTestImplicitOptionalProperties() {
        let ramlString =
        """
        #%RAML 1.0
        title: ToDo List
        types:
          TodoItem:
            properties:
              id:
                (primaryKey):
                (autoUUID):
                required: true
                type: string
              title: string
              createdAt: datetime
              updatedAt: datetime
              doneAt?: datetime
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let optionalDoneAtProperty = raml.typeWith(name: "TodoItem")?.propertyWith(name: "doneAt?") else {
            XCTFail("No doneAt? Property")
            return
        }
        XCTAssertNil(optionalDoneAtProperty.required)
        
        let ramlWithDefaults = raml.applyDefaults()
        
        guard let optionalDoneAtPropertyWithDefaults = ramlWithDefaults.typeWith(name: "TodoItem")?.propertyWith(name: "doneAt") else {
            XCTFail("No doneAt Property")
            return
        }
        XCTAssertEqual(optionalDoneAtPropertyWithDefaults.required, false)
    }
    
}

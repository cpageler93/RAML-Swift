//
//  PropertyRestrictionTests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 26.06.17.
//

import XCTest
@testable import RAML

class PropertyRestrictionTests: XCTestCase {
    
    func testStringRestrictions() {
        let ramlString =
        """
        #%RAML 1.0
        title: Property Restriction Tests
        types:
          Email:
            type: string
            minLength: 2
            maxLength: 6
            pattern: ^note\\d+$
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let emailType = raml.typeWith(name: "Email") else {
            XCTFail("No Email Type")
            return
        }
        XCTAssertEqual(emailType.type, DataType.scalar(type: .string))
        
        guard let stringRestrictions = emailType.restrictions as? StringRestrictions else {
            XCTFail("No Email Type Property Restrictions")
            return
        }
        
        XCTAssertEqual(stringRestrictions.minLength, 2)
        XCTAssertEqual(stringRestrictions.maxLength, 6)
        XCTAssertEqual(stringRestrictions.pattern, "^note\\d+$")
    }
    
    func testNumberRestrictions() {
        let ramlString =
        """
        #%RAML 1.0
        title: String Tests
        types:
          Weight:
            type: number
            minimum: 3
            maximum: 5
            format: int64
            multipleOf: 4
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let weightType = raml.typeWith(name: "Weight") else {
            XCTFail("No Weight Type")
            return
        }
        XCTAssertEqual(weightType.type, DataType.scalar(type: .number))
        
        guard let numberRestrictions = weightType.restrictions as? NumberRestrictions else {
            XCTFail("No Weight Type Property Restrictions")
            return
        }
        
        XCTAssertEqual(numberRestrictions.minimum, 3)
        XCTAssertEqual(numberRestrictions.maximum, 5)
        XCTAssertEqual(numberRestrictions.format, NumberRestrictions.NumberRestrictionFormat.int64)
        XCTAssertEqual(numberRestrictions.multipleOf, 4)
    }
    
    func testFileRestrictions() {
        let ramlString =
        """
        #%RAML 1.0
        title: File Tests
        types:
          userPicture:
            type: file
            fileTypes: ['image/jpeg', 'image/png']
            maxLength: 307200
          customFile:
            type: file
            fileTypes: ['*/*']
            maxLength: 1048576
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let userPictureType = raml.typeWith(name: "userPicture") else {
            XCTFail("No userPicture type")
            return
        }
        XCTAssertEqual(userPictureType.type, DataType.scalar(type: .file))
        
        guard let userPictureFileRestrictions = userPictureType.restrictions as? FileRestrictions else {
            XCTFail("No userPicture Property Restrictions")
            return
        }
        XCTAssertTrue(userPictureFileRestrictions.hasFileTypeWith(identifier: "image/jpeg"))
        XCTAssertTrue(userPictureFileRestrictions.hasFileTypeWith(identifier: "image/png"))
        XCTAssertEqual(userPictureFileRestrictions.maxLength, 307200)
        
        
        guard let customFileType = raml.typeWith(name: "customFile") else {
            XCTFail("No customFile Type")
            return
        }
        XCTAssertEqual(customFileType.type, DataType.scalar(type: .file))
        
        guard let customFileRestrictions = customFileType.restrictions as? FileRestrictions else {
            XCTFail("No customFile Property Restrictions")
            return
        }
        XCTAssertTrue(customFileRestrictions.hasFileTypeWith(identifier: "*/*"))
        XCTAssertEqual(customFileRestrictions.maxLength, 1048576)
    }
    
}

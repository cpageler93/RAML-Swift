//
//  PropertyRestrictionsFromStringTests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 26.06.17.
//

import XCTest
@testable import RAML

class PropertyRestrictionsFromStringTests: XCTestCase {
    
    func testStringRestrictions() {
        let ramlString =
        """
        #%RAML 1.0
        title: String Tests
        types:
          Email:
            type: string
            minLength: 2
            maxLength: 6
            pattern: ^note\\d+$
        """
        
        do {
            let raml = try RAML(string: ramlString)
            guard let emailType = raml.type(withName: "Email") else {
                XCTFail()
                return
            }
            XCTAssertEqual(emailType.type, DataType.scalar(type: .string))
            
            guard let stringRestrictions = emailType.restrictions as? StringRestrictions else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(stringRestrictions.minLength, 2)
            XCTAssertEqual(stringRestrictions.maxLength, 6)
            XCTAssertEqual(stringRestrictions.pattern, "^note\\d+$")
            
        } catch {
            
        }
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
        
        do {
            let raml = try RAML(string: ramlString)
            guard let weightType = raml.type(withName: "Weight") else {
                XCTFail()
                return
            }
            XCTAssertEqual(weightType.type, DataType.scalar(type: .number))
            
            guard let numberRestrictions = weightType.restrictions as? NumberRestrictions else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(numberRestrictions.minimum, 3)
            XCTAssertEqual(numberRestrictions.maximum, 5)
            XCTAssertEqual(numberRestrictions.format, NumberRestrictions.NumberRestrictionFormat.int64)
            XCTAssertEqual(numberRestrictions.multipleOf, 4)
            
        } catch {
            
        }
    }
    
}

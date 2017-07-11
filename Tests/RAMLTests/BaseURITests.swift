//
//  BaseURITests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 10.07.17.
//

import XCTest
@testable import RAML

class BaseURITests: XCTestCase {
    
    func testBaseURIWithVersionParameter() {
        let ramlString =
        """
        #%RAML 1.0
        title: Salesforce Chatter REST API
        version: v28.0
        baseUri: https://na1.salesforce.com/services/data/{version}/chatter
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let baseURI = raml.baseURI else {
            XCTFail("No BaseURI")
            return
        }
        
        XCTAssertEqual(baseURI.value, "https://na1.salesforce.com/services/data/{version}/chatter")
    }
    
    // TODO: Test BASE URI with version parameter
    
    func testBaseURIWithExplicitURIParameters() {
        let ramlString =
        """
        #%RAML 1.0
        title: Amazon S3 REST API
        baseUri: https://{bucketName}.s3.amazonaws.com
        baseUriParameters:
          bucketName:
            description: The name of the bucket
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let baseURI = raml.baseURI else {
            XCTFail("No BaseURI")
            return
        }
        
        guard let baseURIParameters = raml.baseURIParameters else {
            XCTFail("No BaseURI Parameters")
            return
        }
        
        XCTAssertEqual(baseURI.value, "https://{bucketName}.s3.amazonaws.com")
        XCTAssertEqual(baseURIParameters.count, 1)
        
        if let firstURIParameter = raml.baseURIParameters?.first {
            XCTAssertEqual(firstURIParameter.description, "The name of the bucket")
        }
    }
    
}

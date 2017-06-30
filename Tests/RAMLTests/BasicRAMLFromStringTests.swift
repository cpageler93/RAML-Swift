import XCTest
@testable import RAML

class BasicRAMLFromStringTests: XCTestCase {
    
    func testParseRamlMissingAttributesInBasicRoot() {
        let ramlString =
        """
        #%RAML 1.0
        foo: bar
        """
        
        do {
            let _ = try RAML(string: ramlString)
            XCTFail("Should fail")
        } catch {
            
        }
    }
    
    func testParseRamlWithWrongRamlVersion() {
        let ramlString =
        """
        #%RAML 0.8
        title: Foo Bar
        """
        
        do {
            let _ = try RAML(string: ramlString)
            XCTFail("Should fail")
        } catch {
            
        }
    }
    
    func testParseVersionShouldBeEmpty() {
        let ramlString =
        """
        #%RAML 1.0
        title: Foo Bar
        version:
        """
        
        do {
            let raml = try RAML(string: ramlString)
            XCTAssertNil(raml.version)
            XCTAssertNil(raml.description)
            XCTAssertNil(raml.baseURI)
            XCTAssertNil(raml.protocols)
            XCTAssertNil(raml.documentation)
        } catch {
            
        }
    }
    
    func testParseProtocols() {
        let ramlString =
        """
        #%RAML 1.0
        title: Test
        protocols: [ HTTP, HTTPS ]
        """
        
        do {
            let raml = try RAML(string: ramlString)
            XCTAssertTrue(raml.protocols?.contains(.http) ?? false)
            XCTAssertTrue(raml.protocols?.contains(.https) ?? false)
        } catch {
            print("error: \(error)")
            XCTFail("Should not fail")
        }
    }
    
    func testParseInvalidProtocol() {
        let ramlString =
        """
        #%RAML 1.0
        title: Test
        protocols: [ HTTP, POP3 ]
        """
        
        do {
            let _ = try RAML(string: ramlString)
            XCTFail("Should fail because POP3 is invalid protocol for RAML")
        } catch {
            
        }
    }
    
    func testParseIncludeFromString() {
        let ramlString =
        """
        #%RAML 1.0
        title: ZEncoder API
        baseUri: https://app.zencoder.com/api
        documentation:
          - title: Home
            content: !include docs/legal.markdown
        """
        
        do {
            let _ = try RAML(string: ramlString)
            XCTFail("Should fail because includes are not possible when loading from string")
        } catch {
            
        }
    }
    
    func testParseBaseURIWithVersionParameter() {
        let ramlString =
        """
        #%RAML 1.0
        title: Salesforce Chatter REST API
        version: v28.0
        baseUri: https://na1.salesforce.com/services/data/{version}/chatter
        """
        
        do {
            let raml = try RAML(string: ramlString)
            XCTAssertEqual(raml.baseURI?.value, "https://na1.salesforce.com/services/data/{version}/chatter")
            XCTAssertEqual(raml.baseURIWithParameter(), "https://na1.salesforce.com/services/data/v28.0/chatter")
        } catch {
            
        }
    }
    
    func testParseBaseURIWithValue() {
        let ramlString =
        """
        #%RAML 1.0
        title: Salesforce Chatter REST API
        version: v28.0
        baseUri:
          value: https://na1.salesforce.com/services/data/{version}/chatter
        """
        
        do {
            let raml = try RAML(string: ramlString)
            XCTAssertEqual(raml.baseURI?.value, "https://na1.salesforce.com/services/data/{version}/chatter")
        } catch {
            
        }
    }
    
    func testParseBaseURIWithExplicitURIParameters() {
        let ramlString =
        """
        #%RAML 1.0
        title: Amazon S3 REST API
        version: 1
        baseUri: https://{bucketName}.s3.amazonaws.com
        baseUriParameters:
          bucketName:
            description: The name of the bucket
        """
        
        do {
            let raml = try RAML(string: ramlString)
            XCTAssertEqual(raml.baseURI?.value, "https://{bucketName}.s3.amazonaws.com")
            XCTAssertEqual(raml.baseURIParameters?.count, 1)
            if let firstURIParameter = raml.baseURIParameters?.first {
                XCTAssertEqual(firstURIParameter.description, "The name of the bucket")
            }
        } catch {
            
        }
    }
    
    func testParseMediaType() {
        let ramlString =
        """
        #%RAML 1.0
        title: New API
        mediaType: application/json
        """
        
        do {
            let raml = try RAML(string: ramlString)
            XCTAssertEqual(raml.mediaTypes?.count, 1)
            if let firstMediaType = raml.mediaTypes?.first {
                XCTAssertEqual(firstMediaType.identifier, "application/json")
            }
        } catch {
            XCTFail()
        }
    }
    
    func testParseMultipleMediaTypes() {
        let ramlString =
        """
        #%RAML 1.0
        title: New API
        mediaType: [ application/xml, application/json ]
        """
        
        do {
            let raml = try RAML(string: ramlString)
            XCTAssertEqual(raml.mediaTypes?.count, 2)
            if let firstMediaType = raml.mediaTypes?.first {
                XCTAssertEqual(firstMediaType.identifier, "application/xml")
            }
        } catch {
            XCTFail()
        }
    }
}

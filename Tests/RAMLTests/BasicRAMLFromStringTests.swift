import XCTest
@testable import RAML

class RAMLTests: XCTestCase {
    
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
    
}

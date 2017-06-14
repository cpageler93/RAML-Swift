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
            let _ = try RAML(ramlString)
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
            let _ = try RAML(ramlString)
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
            let raml = try RAML(ramlString)
            XCTAssertNil(raml.version)
        } catch {
            
        }
    }
    
    func testParseRamlBasicRoot() {
        
        let ramlString =
        """
        #%RAML 1.0
        title: GitHub API
        version: v3
        baseUri: https://api.github.com
        mediaType:  application/json
        securitySchemes:
          oauth_2_0: !include securitySchemes/oauth_2_0.raml
        types:
          Gist:  !include types/gist.raml
          Gists: !include types/gists.raml
        resourceTypes:
          collection: !include types/collection.raml
        traits:
        securedBy: [ oauth_2_0 ]
        /search:
          /code:
            type: collection
            get:
        """
        
        do {
            let raml = try RAML(ramlString)
            XCTAssertEqual(raml.title, "GitHub API")
            XCTAssertEqual(raml.version, "v3")
            XCTAssertEqual(raml.baseURI, "https://api.github.com")
        } catch {
            print("error: \(error)")
            XCTFail("Should not fail")
        }
    }
    
    func testParseBasicDocumentation() {
        let ramlString =
        """
        #%RAML 1.0
        title: ZEncoder API
        baseUri: https://app.zencoder.com/api
        documentation:
         - title: Home
           content: |
             Welcome to the _Zencoder API_ Documentation. The _Zencoder API_
             allows you to connect your application to our encoding service
             and encode videos without going through the web  interface. You
             may also benefit from one of our
             [integration libraries](https://app.zencoder.com/docs/faq/basics/libraries)
             for different languages.
         - title: Legal
           content: !include docs/legal.markdown
        """
        
        do {
            let raml = try RAML(ramlString)
            XCTAssertEqual(raml.documentation?.count, 2)
            
        } catch {
            print("error: \(error)")
            XCTFail("Should not fail")
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
            let raml = try RAML(ramlString)
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
            let _ = try RAML(ramlString)
            XCTFail("Should fail because POP3 is invalid protocol for RAML")
        } catch {
            
        }
    }
    
}

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
    
    
}

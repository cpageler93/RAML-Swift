import XCTest
@testable import RAML

class RAMLTests: XCTestCase {
    
    func testParseRamlWithoutTitle() {
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
    
    func testParseRaml10Title() {
        
        let ramlString =
        """
        #%RAML 1.0
        title: My API
        """
        
        do {
            let raml = try RAML(ramlString)
            XCTAssertEqual(raml.title, "My API")
        } catch {
            XCTFail("Should not fail")
        }
    }
}

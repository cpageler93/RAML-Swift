//
//  RAMLResourcesTests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 24.07.17.
//

import XCTest
@testable import RAML

class RAMLEnumeratorTests: XCTestCase {
    
    func testResourceEnumeration() {
        let ramlString =
        """
        #%RAML 1.0
        title: GitHub API
        version: v3
        baseUri: https://api.github.com
        /gists:
          displayName: Gists
          /public:
            displayName: Public Gists
        /foo:
          displayName: Foo
          /bar:
            displayName: Bar
        """
        
        guard let raml = try? RAML(string: ramlString).applyDefaults() else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        var paths = [
            "/gists",
            "/public",
            "/foo",
            "/bar"
        ]
        
        raml.enumerateResource { resource, _, _ in
            guard let index = paths.index(of: resource.path) else {
                XCTFail("Path \(resource.path) not found")
                return
            }
            paths.remove(at: index)
        }
        XCTAssertEqual(paths.count, 0)
    }
    
    func testResourceAbsolutePaths() {
        let ramlString =
        """
        #%RAML 1.0
        title: GitHub API
        version: v3
        baseUri: https://api.github.com
        /gists:
          displayName: Gists
          /public:
            displayName: Public Gists
        /foo:
          displayName: Foo
          /bar:
            displayName: Bar
        """
        
        guard let raml = try? RAML(string: ramlString).applyDefaults() else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let gistsResource = raml.resourceWith(path: "/gists") else {
            XCTFail("No /gists resource")
            return
        }
        XCTAssertEqual(raml.absolutePathForResource(gistsResource), "/gists")
        
        guard let gistsPublicResource = raml.resourceWith(path: "/gists")?.resourceWith(path: "/public") else {
            XCTFail("No /gists resource")
            return
        }
        XCTAssertEqual(raml.absolutePathForResource(gistsPublicResource), "/gists/public")
    }
    
}

//
//  GitHubExampleTests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 24.06.17.
//

import XCTest
@testable import RAML

class GitHubExampleTests: XCTestCase {
    
    var raml: RAML!
    
    override func setUp() {
        super.setUp()
        
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "main",
                                     ofType: "raml",
                                     inDirectory: "TestData/GitHub") else {
            XCTFail()
            return
        }
        do {
            raml = try RAML(file: path)
        } catch {
            print("error: \(error)")
            XCTFail()
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBasicData() {
        XCTAssertEqual(raml.title, "GitHub API")
        XCTAssertEqual(raml.description, "Description of GitHub API")
        XCTAssertEqual(raml.version, "v3")
        XCTAssertEqual(raml.baseURI?.value, "https://api.github.com")
    }
}

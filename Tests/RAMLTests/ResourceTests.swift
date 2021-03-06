//
//  ResourceTests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 30.06.17.
//

import XCTest
@testable import RAML

class ResourceTests: XCTestCase {
    
    func testBasicResource() {
        let ramlString =
        """
        #%RAML 1.0
        title: Resource Tests
        /list:
          get:
            responses:
              200:
                body: Person[]
        /send:
          post:
            body:
              application/json:
                type: Another
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let resources = raml.resources else {
            XCTFail("No Resources")
            return
        }
        XCTAssertEqual(resources.count, 2)
        
        guard let listResource = raml.resourceWith(path: "/list") else {
            XCTFail("No /list Resource")
            return
        }
        XCTAssertNil(listResource.annotations)
        XCTAssertNil(listResource.description)
        XCTAssertNil(listResource.displayName)
        
        guard let listMethods = listResource.methods else {
            XCTFail("No Methods in /list Resource")
            return
        }
        
        XCTAssertEqual(listMethods.count, 1)
        
        guard let listGet = listResource.methodWith(type: .get) else {
            XCTFail("No GET Method in /list Resource")
            return
        }
        
        guard let listGetResponses = listGet.responses else {
            XCTFail("No Responses in GET /list")
            return
        }
        XCTAssertEqual(listGetResponses.count, 1)
        
        guard let listGet200 = listGet.responseWith(code: 200) else {
            XCTFail("No 200 Response for GET /list")
            return
        }
        
        guard let listGet200Body = listGet200.body else {
            XCTFail("No Body in 200 GET /list")
            return
        }
        
        XCTAssertEqual(listGet200Body.type, DataType.array(ofType: .custom(type: "Person")))
        
        
        
        //
        // /send:
        //   post:
        //     body:
        //       application/json:
        //         type: Another
        //
        guard let sendResource = raml.resourceWith(path: "/send") else {
            XCTFail("No send resource")
            return
        }
        XCTAssertNil(sendResource.annotations)
        XCTAssertNil(sendResource.description)
        XCTAssertNil(sendResource.displayName)
        
        guard let sendMethods = sendResource.methods else {
            XCTFail("No Methods in send resource")
            return
        }
        XCTAssertEqual(sendMethods.count, 1)
        
        guard let postSend = sendResource.methodWith(type: .post) else {
            XCTFail("No POST method in /send")
            return
        }
        XCTAssertNil(postSend.responses)
        
        guard let postBody = postSend.body else {
            XCTFail("No Body in POST /send")
            return
        }
        
        guard let postBodyMediaTypes = postBody.mediaTypes else {
            XCTFail("No MediaTypes in POST /send Body")
            return
        }
        XCTAssertEqual(postBodyMediaTypes.count, 1)
        
        guard let postSendJson = postBody.mediaTypeWith(identifier: "application/json") else {
            XCTFail("No application/json in POST /send Body")
            return
        }
        
        XCTAssertEqual(postSendJson.type, DataType.custom(type: "Another"))
        
    }
    
    func testHeadersInResources() {
        let ramlString =
        """
        #%RAML 1.0
        title: Resource Tests
        /jobs:
          post:
            headers:
              Zencoder-Api-Key:
                description: The API key needed to create a new job
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let jobsResource = raml.resourceWith(path: "/jobs") else {
            XCTFail("No /jobs Resource")
            return
        }
        
        guard let postMethod = jobsResource.methodWith(type: .post) else {
            XCTFail("No POST method for /jobs Resource")
            return
        }
        
        guard let headers = postMethod.headers else {
            XCTFail("No Headers in POST /jobs")
            return
        }
        
        XCTAssertEqual(headers.count, 1)
        guard let apiKeyHeader = postMethod.headerWith(key: "Zencoder-Api-Key") else {
            XCTFail("No ApiKey Header")
            return
        }
        XCTAssertEqual(apiKeyHeader.description, "The API key needed to create a new job")
        
    }
    
    func testTraitsAndHeadersWithArrayAndPatternsInResources() {
        let ramlString =
        """
        #%RAML 1.0
        title: Example with headers
        /users:
          get:
            is: [ chargeable, traceable ]
            description: |
              The HTTP interaction will look like

              GET /users HTTP/1.1
              X-Dept: 18-FINANCE
              X-Dept: 200-MISC
              X-Tracker: gfr456d03ygh38s2
            headers:
              X-Dept:
                example: [ 18-FINANCE, 200-MISC ]
              X-Tracker:
                example: gfr456d03ygh38s2
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let usersResource = raml.resourceWith(path: "/users") else {
            XCTFail("No /users Resource")
            return
        }
        
        guard let getUsers = usersResource.methodWith(type: .get) else {
            XCTFail("No GET method for /users Resource")
            return
        }
        
        guard let traitUsages = getUsers.traitUsages else {
            XCTFail("No Trait Usages for GET /users")
            return
        }
        XCTAssertEqual(traitUsages.count, 2)
        
        XCTAssertTrue(getUsers.hasTraitUsageWith(name: "chargeable"))
        XCTAssertTrue(getUsers.hasTraitUsageWith(name: "traceable"))
        
        guard let headers = getUsers.headers else {
            XCTFail("No Headers in GET /users")
            return
        }
        XCTAssertEqual(headers.count, 2)
        
        guard let xDeptHeader = getUsers.headerWith(key: "X-Dept") else {
            XCTFail("No X-Dept Header in GET /users")
            return
        }
        // TODO: FIX EXAMPLE TO NOT ONLY BE A STRING
        XCTAssertNil(xDeptHeader.example)
        
        guard let xTrackerHeader = getUsers.headerWith(key: "X-Tracker") else {
            XCTFail("No X-Tracker Header in GET /users")
            return
        }
        
        XCTAssertEqual(xTrackerHeader.example, "gfr456d03ygh38s2")
    }
    
    func testNestedResources() {
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
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let gistsResource = raml.resourceWith(path: "/gists") else {
            XCTFail("No /gists Resource")
            return
        }
        XCTAssertEqual(gistsResource.displayName, "Gists")
        
        guard let publicResource = gistsResource.resourceWith(path: "/public") else {
            XCTFail("No /gists/public Resource")
            return
        }
        XCTAssertEqual(publicResource.displayName, "Public Gists")
        
    }
    
    func testQueryParameters() {
        let ramlString =
        """
        #%RAML 1.0
        title: GitHub API
        version: v3
        baseUri: https://api.github.com/{version}
        /users:
          get:
            description: Get a list of users
            queryParameters:
              page:
                description: Specify the page that you want to retrieve
                type:        integer
                required:    true
                example:     1
              per_page:
                description: Specify the amount of items that will be retrieved per page
                type:        integer
                minimum:     10
                maximum:     200
                default:     30
                example:     50
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let usersRoute = raml.resourceWith(path: "/users")?.methodWith(type: .get) else {
            XCTFail("No /users GET Resource")
            return
        }
        XCTAssertEqual(usersRoute.description, "Get a list of users")
        guard let queryParameters = usersRoute.queryParameters else {
            XCTFail("No Query Parameters for users resource")
            return
        }
        XCTAssertEqual(queryParameters.count, 2)
        
        guard let pageParameter = usersRoute.queryParameterWith(identifier: "page") else {
            XCTFail("No page Parameter")
            return
        }
        XCTAssertEqual(pageParameter.description, "Specify the page that you want to retrieve")
        XCTAssertEqual(pageParameter.type, URIParameter.ParameterType.integer)
        XCTAssertEqual(pageParameter.required, true)
        XCTAssertEqual(pageParameter.example, 1)
        XCTAssertNil(pageParameter.minimum)
        XCTAssertNil(pageParameter.maximum)
        XCTAssertNil(pageParameter.default)
        
        guard let perPageParameter = usersRoute.queryParameterWith(identifier: "per_page") else {
            XCTFail("No per_page Parameter")
            return
        }
        XCTAssertEqual(perPageParameter.description, "Specify the amount of items that will be retrieved per page")
        XCTAssertEqual(perPageParameter.type, URIParameter.ParameterType.integer)
        XCTAssertNil(perPageParameter.required)
        XCTAssertEqual(perPageParameter.example, 50)
        XCTAssertEqual(perPageParameter.minimum, 10)
        XCTAssertEqual(perPageParameter.maximum, 200)
        XCTAssertEqual(perPageParameter.default, 30)
    }
    
    func testQueryString() {
        let ramlString =
        """
        #%RAML 1.0
        title: Illustrate query parameter variations
        types:
          lat-long:
            properties:
              lat: number
              long: number
          loc:
            properties:
              location:
          paging:
            properties:
              start?: number
              page-size?: number
        /locations:
          get:
            queryString:
              type: [paging, lat-long | loc ]
              examples:
                first:
                  value:
                    start: 2
                    lat: 12
                    long: 13
                second:
                  value:
                    start: 2
                    page-size: 20
                    location: "1,2"
                third:
                  value:
                    lat: 12
                    location: 2
                  strict: false
        """
        
        guard let raml = try? RAML(string: ramlString) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        guard let locationsResource = raml.resourceWith(path: "/locations")?.methodWith(type: .get) else {
            XCTFail("No /locations GET Resource")
            return
        }
        
        guard let queryString = locationsResource.queryString else {
            XCTFail("No Query String for locations Resource")
            return
        }
        XCTAssertEqual(queryString.type, DataType.union(types: [DataType.custom(type: "paging"), DataType.union(types: [DataType.custom(type: "lat-long"), DataType.custom(type: "loc")])]))
        
        guard let examples = queryString.examples else {
            XCTFail("No Examples")
            return
        }
        XCTAssertEqual(examples.count, 3)
        
        guard let firstExample = queryString.exampleWith(identifier: "first") else {
            XCTFail("No first exampe")
            return
        }
        XCTAssertNotNil(firstExample.value)
        XCTAssertNil(firstExample.strict)
        XCTAssertNil(firstExample.description)
        XCTAssertNil(firstExample.displayName)
        XCTAssertNil(firstExample.annotations)
        
        guard let thirdExample = queryString.exampleWith(identifier: "third") else {
            XCTFail("No third example")
            return
        }
        XCTAssertFalse(thirdExample.strict ?? true)
    }
}

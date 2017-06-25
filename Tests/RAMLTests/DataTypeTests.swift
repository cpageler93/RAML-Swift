//
//  DataTypeTests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 25.06.17.
//

import XCTest
@testable import RAML

class DataTypeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDataTypes() {
        XCTAssertEqual(DataType.any, DataType.any)
        XCTAssertEqual(DataType.object, DataType.object)
        XCTAssertEqual(DataType.array(ofType: .object), DataType.array(ofType: .object))
        XCTAssertEqual(DataType.union(types: [.object, .scalar(type: .number)]), DataType.union(types: [.object, .scalar(type: .number)]))
        XCTAssertEqual(DataType.scalar(type: .boolean), DataType.scalar(type: .boolean))
        
        XCTAssertNotEqual(DataType.any, DataType.object)
    }
}

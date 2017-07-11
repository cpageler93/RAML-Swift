//
//  DataTypeTests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 25.06.17.
//

import XCTest
@testable import RAML

class DataTypeTests: XCTestCase {
    
    func testDataTypes() {
        XCTAssertEqual(DataType.any, DataType.any)
        XCTAssertEqual(DataType.object, DataType.object)
        XCTAssertEqual(DataType.array(ofType: .object), DataType.array(ofType: .object))
        XCTAssertEqual(DataType.union(types: [.object, .scalar(type: .number)]), DataType.union(types: [.object, .scalar(type: .number)]))
        XCTAssertEqual(DataType.scalar(type: .boolean), DataType.scalar(type: .boolean))
        XCTAssertEqual(DataType.custom(type: "FooBar"), DataType.custom(type: "FooBar"))
        
        XCTAssertNotEqual(DataType.any, DataType.object)
        XCTAssertNotEqual(DataType.custom(type: "FooBar"), DataType.custom(type: "NotFooBar"))
    }
}

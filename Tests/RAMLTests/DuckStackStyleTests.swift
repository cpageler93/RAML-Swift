//
//  DuckStackStyleTests.swift
//  RAMLTests
//
//  Created by Christoph Pageler on 06.08.17.
//

import XCTest
@testable import RAML

class DuckStackStyleTests: XCTestCase {
    
    func testDuckStackStyle() {
        
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "todolist", ofType: "raml", inDirectory: "TestData/DuckStackStyle") else {
            XCTFail("No Path to todolist.raml in TestData/DuckStackStyle")
            return
        }
        
        guard let raml = try? RAML(file: path) else {
            XCTFail("Parsing should not throw an error")
            return
        }
        
        XCTAssertEqual(raml.title, "ToDo List")
        XCTAssertEqual(raml.version, "v1")
        
        XCTAssertEqual(raml.documentation?.count, 1)
        
        guard let homeDocumentation = raml.documentationEntryWith(title: "Home") else {
            XCTFail("No homeDocumentation Entry")
            return
        }
        XCTAssertEqual(homeDocumentation.content, "ToDo List API")
        
        
        guard let todoItemType = raml.typeWith(name: "TodoItem") else {
            XCTFail("No ToDoItem Type")
            return
        }
        
        guard let todoItemProperties = todoItemType.properties else {
            XCTFail("No Properties for todoItem")
            return
        }
        XCTAssertEqual(todoItemProperties.count, 5)
        
        guard let idProperty = todoItemType.propertyWith(name: "id") else {
            XCTFail("No id property in type todoItem")
            return
        }
        
        XCTAssertTrue(idProperty.required ?? false)
        XCTAssertEqual(idProperty.type, DataType.scalar(type: .string))
        XCTAssertTrue(idProperty.hasAnnotationWith(name: "primaryKey"))
        XCTAssertTrue(idProperty.hasAnnotationWith(name: "autoUUID"))
    }
    
}

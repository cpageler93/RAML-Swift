//
//  Type.swift
//  RAML
//
//  Created by Christoph Pageler on 24.06.17.
//

import Foundation
import Yaml

public class Type {
    
    public var name: String
    // default?
    public var type: DataType?
    public var example: TypeExample?
    public var examples: [TypeExample]?
    public var displayName: String?
    public var description: String?
    // annotations?
    // facets?
    // xml?
    // enum?
    
    // MARK: Object Type
    
    var properties: [Property]?
    var minProperties: Int?
    var maxProperties: Int?
    var additionalProperties: Bool = true
    var discriminator: String?
    var discriminatorValue: String?
    
    init(name: String) {
        self.name = name
        
    }
    
}

// MARK: Type Parsing
extension RAML {
    
    internal func parseTypes(_ yaml: [Yaml: Yaml]) throws -> [Type] {
        var types: [Type] = []
        for (key, value) in yaml {
            guard let keyString = key.string else { throw RAMLError.ramlParsingError(message: "type key must be a string `\(key)`") }
            let type = parseType(name: keyString, yaml: value)
            types.append(type)
        }
        return types
    }
    
    private func parseType(name: String, yaml: Yaml) -> Type {
        let type = Type(name: name)
        
        if let typeString = yaml["type"].string {
            type.type = typeEnumFrom(string: typeString)
        }
        
        return type
    }
    
    private func typeEnumFrom(string: String) -> DataType {
        if string == "object" {
            return .object
        } else if string.hasSuffix("[]") {
            let arrayType = String(string.dropLast(2))
            return .array(ofType: typeEnumFrom(string: arrayType))
        }
        return .custom(type: string)
    }
    
}

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
    
    public func property(withName name: String) -> Property? {
        for property in properties ?? [] {
            if property.name == name {
                return property
            }
        }
        return nil
    }
    
}

// MARK: Type Parsing
extension RAML {
    
    internal func parseTypes(_ yaml: [Yaml: Yaml]) throws -> [Type] {
        var types: [Type] = []
        for (key, value) in yaml {
            guard let keyString = key.string else { throw RAMLError.ramlParsingError(message: "type key must be a string `\(key)`") }
            
            let type = parseType(name: keyString, yaml: value)
            
            if let yamlProperties = value["properties"].dictionary {
                type.properties = try parseProperties(yamlProperties)
            }
            
            types.append(type)
        }
        return types
    }
    
    private func parseType(name: String, yaml: Yaml) -> Type {
        let type = Type(name: name)
        
        if let typeString = yaml["type"].string {
            type.type = DataType.dataTypeEnumFrom(string: typeString)
        }
        
        return type
    }
}

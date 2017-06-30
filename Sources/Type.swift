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
    public var properties: [Property]?
    public var minProperties: Int?
    public var maxProperties: Int?
    public var additionalProperties: Bool = true
    public var discriminator: String?
    public var discriminatorValue: String?
    
    
    // MARK: Scalar Type
    public var restrictions: PropertyRestrictions?
    
    public init(name: String) {
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
            let type = try parseType(name: keyString, yaml: value)
            types.append(type)
        }
        return types
    }
    
    private func parseType(name: String, yaml: Yaml) throws -> Type {
        let type = Type(name: name)
        
        if let typeString = yaml["type"].string {
            type.type = DataType.dataTypeEnumFrom(string: typeString)
        }
        
        if let yamlProperties = yaml["properties"].dictionary {
            type.properties = try parseProperties(yamlProperties)
        }
        
        type.restrictions = try parseRestrictions(forType: type, yaml: yaml)
        
        return type
    }
    
    private func parseRestrictions(forType type: Type, yaml: Yaml) throws -> PropertyRestrictions? {
        guard let dataType = type.type else { return nil }
        switch dataType {
        case .scalar(type: let scalarType):
            switch scalarType {
            case .string: return try parseStringRestrictions(yaml)
            case .number: return try parseNumberRestrictions(yaml)
            default: return nil
            }
        default: return nil
        }
    }
    
    private func parseStringRestrictions(_ yaml: Yaml) throws -> StringRestrictions? {
        let restrictions = StringRestrictions()
        
        restrictions.pattern = yaml["pattern"].string
        restrictions.minLength = yaml["minLength"].int
        restrictions.maxLength = yaml["maxLength"].int
        
        return restrictions
    }
    
    private func parseNumberRestrictions(_ yaml: Yaml) throws -> NumberRestrictions? {
        let restrictions = NumberRestrictions()
        
        restrictions.minimum = yaml["minimum"].int
        restrictions.maximum = yaml["maximum"].int
        if let formatString = yaml["format"].string {
            restrictions.format = NumberRestrictions.NumberRestrictionFormat(rawValue: formatString)
        }
        restrictions.multipleOf = yaml["multipleOf"].int
        
        return restrictions
    }
}

public protocol HasTypes {
    var types: [Type]? { get set }
}

extension HasTypes {
    
    public func type(withName name: String) -> Type? {
        for type in types ?? [] {
            if type.name == name {
                return type
            }
        }
        return nil
    }
    
}

//
//  Type.swift
//  RAML
//
//  Created by Christoph Pageler on 24.06.17.
//

import Foundation
import Yaml

public class Type: HasProperties {
    
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
}


// MARK: Type Parsing
extension RAML {
    
    internal func parseTypes(_ yaml: [Yaml: Yaml]) throws -> [Type] {
        var types: [Type] = []
        for (key, value) in yaml {
            guard let keyString = key.string else {
                throw RAMLError.ramlParsingError(.invalidDataType(for: "type key",
                                                                  mustBeKindOf: "String"))
            }
            let type = try parseType(name: keyString, yaml: value)
            types.append(type)
        }
        return types
    }
    
    private func parseType(name: String, yaml: Yaml) throws -> Type {
        let type = Type(name: name)
        
        if let yamlString = yaml.string {
            type.type = DataType.dataTypeEnumFrom(string: yamlString)
        } else if let yamlDict = yaml.dictionary {
            if let typeString = yamlDict["type"]?.string {
                type.type = DataType.dataTypeEnumFrom(string: typeString)
            }
            
            if let yamlProperties = yamlDict["properties"]?.dictionary {
                type.properties = try parseProperties(yamlProperties)
                type.type = .object
            } else {
                // no properties as dictionary.. check if properties is empty key
                for (key, _) in yamlDict {
                    guard let keyString = key.string else { continue }
                    
                    // if there is an empty properties key and type isnt already set
                    if keyString == "properties" && type.type == nil {
                        type.type = .object
                    }
                }
            }
        }
        
        
        // if we havent figured out the type, set type to string
        if type.type == nil {
            type.type = .scalar(type: .string)
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


public extension HasTypes {
    
    public func typeWith(name: String) -> Type? {
        for type in types ?? [] {
            if type.name == name {
                return type
            }
        }
        return nil
    }
    
    public func hasTypeWith(name: String) -> Bool {
        return typeWith(name: name) != nil
    }
    
}

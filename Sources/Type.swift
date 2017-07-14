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
    public var additionalProperties: Bool?
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
    
    internal func parseTypes(_ input: ParseInput) throws -> [Type]? {
        guard let yaml = input.yaml else { return nil }
        
        switch yaml {
        case .dictionary(let yamlDict):
            return try parseTypes(dict: yamlDict)
        default:
            return nil
        }
        
        // TODO: Consider Includes
    }
    
    private func parseTypes(dict: [Yaml: Yaml]) throws -> [Type] {
        var types: [Type] = []
        for (key, value) in dict {
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
        
        type.type = try DataType.dataTypeEnumFrom(yaml: yaml, dictKey: "type")
        type.properties = try parseProperties(yaml: yaml, propertiesKey: "properties")
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
        default:
            return nil
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

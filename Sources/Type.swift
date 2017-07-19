//
//  Type.swift
//  RAML
//
//  Created by Christoph Pageler on 24.06.17.
//

import Foundation
import Yaml
import PathKit

public class Type: HasProperties, HasAnnotations, HasExamples {
    
    public var name: String
    // default?
    public var type: DataType?
    public var example: Example?
    public var examples: [Example]?
    public var displayName: String?
    public var description: String?
    public var annotations: [Annotation]?
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
    
    // MARK: Array Type
    public var uniqueItems: Bool?
    public var items: DataType?
    public var minItems: Int?
    public var maxItems: Int?
    
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
            return try parseTypes(dict: yamlDict, parentFilePath: input.parentFilePath)
        default:
            return nil
        }
        
        // TODO: Consider Includes
    }
    
    private func parseTypes(dict: [Yaml: Yaml], parentFilePath: Path?) throws -> [Type] {
        var types: [Type] = []
        for (key, value) in dict {
            guard let keyString = key.string else {
                throw RAMLError.ramlParsingError(.invalidDataType(for: "type key",
                                                                  mustBeKindOf: "String"))
            }
            let type = try parseType(name: keyString, yaml: value, parentFilePath: parentFilePath)
            types.append(type)
        }
        return types
    }
    
    private func parseType(name: String, yaml: Yaml, parentFilePath: Path?) throws -> Type {
        let type = Type(name: name)
        
        type.type                   = try DataType.dataTypeEnumFrom(yaml: yaml, dictKey: "type")
        type.annotations            = try parseAnnotations(ParseInput(yaml, parentFilePath))
        type.examples               = try parseExamples(ParseInput(yaml["examples"], parentFilePath))
        
        // Object Type
        type.properties             = try parseProperties(yaml: yaml, propertiesKey: "properties")
        type.minProperties          = yaml["minProperties"].int
        type.maxProperties          = yaml["maxProperties"].int
        type.additionalProperties   = yaml["additionalProperties"].bool
        type.discriminator          = yaml["discriminator"].string
        type.discriminatorValue     = yaml["discriminatorValue"].string
        
        // Array Type
        type.uniqueItems            = yaml["uniqueItems"].bool
        type.items                  = try DataType.dataTypeEnumFrom(yaml: yaml, dictKey: "items")
        type.minItems               = yaml["minItems"].int
        type.maxItems               = yaml["maxItems"].int
        
        // Scalar Type
        type.restrictions   = try parseRestrictions(forType: type, yaml: yaml)
        
        return type
    }
    
    private func parseRestrictions(forType type: Type, yaml: Yaml) throws -> PropertyRestrictions? {
        guard let dataType = type.type else { return nil }
        switch dataType {
        case .scalar(type: let scalarType):
            switch scalarType {
            case .string: return try parseStringRestrictions(yaml)
            case .number: return try parseNumberRestrictions(yaml)
            case .file: return try parseFileRestrictions(yaml)
            default: return nil
            }
        default:
            return nil
        }
    }
    
    private func parseStringRestrictions(_ yaml: Yaml) throws -> StringRestrictions? {
        let restrictions = StringRestrictions()
        
        restrictions.pattern    = yaml["pattern"].string
        restrictions.minLength  = yaml["minLength"].int
        restrictions.maxLength  = yaml["maxLength"].int
        
        return restrictions
    }
    
    private func parseNumberRestrictions(_ yaml: Yaml) throws -> NumberRestrictions? {
        let restrictions = NumberRestrictions()
        
        restrictions.minimum    = yaml["minimum"].int
        restrictions.maximum    = yaml["maximum"].int
        if let formatString     = yaml["format"].string {
            restrictions.format = NumberRestrictions.NumberRestrictionFormat(rawValue: formatString)
        }
        restrictions.multipleOf = yaml["multipleOf"].int
        
        return restrictions
    }
    
    private func parseFileRestrictions(_ yaml: Yaml) throws -> FileRestrictions? {
        let restrictions = FileRestrictions()
        
        restrictions.fileTypes  = try parseMediaTypes(ParseInput(yaml["fileTypes"]))
        restrictions.minLength  = yaml["minLength"].int
        restrictions.maxLength  = yaml["maxLength"].int
        
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

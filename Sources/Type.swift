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
    
    internal init() {
        self.name = ""
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
        type.examples               = try parseExampleOrExamples(yamlDict: yaml.dictionary)
        
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
        type.restrictions   = try parseRestrictions(forType: type.type, yaml: yaml)
        
        return type
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


// MARK: Default Values
public extension Type {
    
    public func typeOrDefaultType() -> DataType? {
        if let type = type { return type }
        
        if properties != nil {
            return DataType.object
        }
        
        return nil
    }
    
    public func discriminatorValueOrDefault() -> String? {
        if let discriminatorValue = discriminatorValue { return discriminatorValue }
        if discriminator == nil {
            return self.name.lowercased()
        }
        return nil
    }
    
    public convenience init(initWithDefaultsBasedOn type: Type) {
        self.init()
        
        self.name                   = type.name
        // default?
        self.type                   = type.typeOrDefaultType()
        self.examples               = type.examples?.map { $0.applyDefaults() }
        self.displayName            = type.displayName
        self.description            = type.description
        self.annotations            = type.annotations?.map { $0.applyDefaults() }
        // facets?
        // xml?
        // enum?
        
        // Object Type
        self.properties             = type.properties?.map { $0.applyDefaults() }
        self.minProperties          = type.minProperties
        self.maxProperties          = type.maxProperties
        self.additionalProperties   = type.additionalProperties ?? true
        self.discriminator          = type.discriminator
        self.discriminatorValue     = type.discriminatorValueOrDefault()
        
        // Array Type
        self.uniqueItems            = type.uniqueItems
        self.items                  = type.items
        self.minItems               = type.minItems ?? 0
        self.maxItems               = type.maxItems ?? 2147483647
        
        // Scalar Type
        self.restrictions           = type.restrictions?.applyDefaults()
    }
    
    public func applyDefaults() -> Type {
        return Type(initWithDefaultsBasedOn: self)
    }
    
}

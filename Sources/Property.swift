//
//  Property.swift
//  RAML
//
//  Created by Christoph Pageler on 24.06.17.
//

import Foundation
import Yaml

public class Property: HasAnnotations {
    
    public var name: String
    public var required: Bool?
    public var type: DataType?
    public var restrictions: PropertyRestrictions?
    public var `enum`: StringEnum?
    public var annotations: [Annotation]?
    
    public init(name: String) {
        self.name = name
    }
    
    internal init() {
        self.name = ""
    }
    
}


// MARK: Property Parsing
internal extension RAML {
    
    internal func parseProperties(yaml: Yaml?, propertiesKey: String = "properties") throws -> [Property]? {
        guard let yaml = yaml else { return nil }
        
        switch yaml {
        case .dictionary(let yamlDict):
            for (key, value) in yamlDict {
                if let keyString = key.string, keyString == propertiesKey {
                    if let valueDict = value.dictionary {
                        return try parseProperties(dict: valueDict)
                    } else {
                        return []
                    }
                }
            }
            return nil
        default: return nil
        }
        
    }
    
    internal func parseProperties(dict: [Yaml: Yaml]) throws -> [Property] {
        var properties: [Property] = []
        for (key, value) in dict {
            guard let keyString = key.string else {
                throw RAMLError.ramlParsingError(.invalidDataType(for: "Property Key",
                                                                  mustBeKindOf: "String"))
            }
            let property = try parseProperty(name: keyString, yaml: value)
            properties.append(property)
        }
        return properties
    }
    
    private func parseProperty(name: String, yaml: Yaml) throws -> Property {
        let property = Property(name: name)
        
        property.required       = yaml["required"].bool
        property.type           = try DataType.dataTypeEnumFrom(yaml: yaml, dictKey: "type")
        if let type = property.type {
            property.restrictions = try parseRestrictions(forType: type, yaml: yaml)
        }
        property.enum           = try parseStringEnum(ParseInput(yaml["enum"]))
        property.annotations    = try parseAnnotations(ParseInput(yaml))
        
        return property
    }
    
}


public protocol HasProperties {
    
    var properties: [Property]? { get set }
    
}


public extension HasProperties {
    
    public func propertyWith(name: String) -> Property? {
        for property in properties ?? [] {
            if property.name == name {
                return property
            }
        }
        return nil
    }
    
    public func hasPropertyWith(name: String) -> Bool {
        return propertyWith(name: name) != nil
    }
    
}


// MARK: Default Values
public extension Property {
    
    public func typeOrDefault() -> DataType? {
        if let type = type { return type }
        return DataType.scalar(type: .string)
    }
    
    public func restrictionsOrDefault() -> PropertyRestrictions? {
        if let restrictions = restrictions { return restrictions.applyDefaults() }
        guard let type = typeOrDefault() else {
            return nil
        }
        
        let newRestrictions = RAML.propertyRestrictionsFor(type: type)
        return newRestrictions?.applyDefaults()
    }
    
    public func nameOrDefault() -> String {
        if name.hasSuffix("?") {
            return String(name.dropLast())
        }
        return name
    }
    
    public func requiredOrDefault() -> Bool {
        if let required = required { return required }
        return !name.hasSuffix("?")
    }
    
    public convenience init(initWithDefaultsBasedOn property: Property) {
        self.init()
        
        self.name           = property.nameOrDefault()
        self.required       = property.requiredOrDefault()
        self.type           = property.typeOrDefault()
        self.restrictions   = property.restrictionsOrDefault()
        self.enum           = property.enum
    }
    
    public func applyDefaults() -> Property {
        return Property(initWithDefaultsBasedOn: self)
    }
    
}

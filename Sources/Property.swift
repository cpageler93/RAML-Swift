//
//  Property.swift
//  RAML
//
//  Created by Christoph Pageler on 24.06.17.
//

import Foundation
import Yaml

public class Property {
    
    public var name: String
    public var required: Bool?
    public var type: DataType?
    public var restrictions: PropertyRestrictions?
    public var `enum`: [String]?
    
    public init(name: String) {
        self.name = name
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
        
        property.required = yaml["required"].bool
        property.type = try DataType.dataTypeEnumFrom(yaml: yaml, dictKey: "type")
        
        // parse enum
        if let yamlEnumArray = yaml["enum"].array {
            var enumValues: [String] = []
            for yamlEnumValue in yamlEnumArray {
                guard let enumString = yamlEnumValue.string else {
                    throw RAMLError.ramlParsingError(.invalidDataType(for: "Enum Value",
                                                                      mustBeKindOf: "String"))
                }
                enumValues.append(enumString)
            }
            property.enum = enumValues
        }
        
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

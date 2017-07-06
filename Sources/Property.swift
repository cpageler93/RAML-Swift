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
    public var required: Bool = true
    public var type: DataType?
    public var restrictions: PropertyRestrictions?
    public var `enum`: [String]?
    
    public init(name: String) {
        self.name = name
    }
    
}

// MARK: Property Parsing
extension RAML {
    
    internal func parseProperties(_ yaml: [Yaml: Yaml]) throws -> [Property] {
        var properties: [Property] = []
        for (key, value) in yaml {
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
        
        // parse required / optional
        if let yamlRequired = yaml["required"].bool {
            property.required = yamlRequired
        } else if name.hasSuffix("?") {
            // if required is not explicity set, check for ? suffix
            property.name = String(name.dropLast())
            property.required = false
        }
        
        // parse type
        if let yamlTypeString = yaml["type"].string {
            property.type = DataType.dataTypeEnumFrom(string: yamlTypeString)
        } else if let yamlString = yaml.string {
            // if type is not explicitly set, check for type in value
            property.type = DataType.dataTypeEnumFrom(string: yamlString)
        }
        
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
    
}

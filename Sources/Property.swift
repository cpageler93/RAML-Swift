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
    
    public init(name: String) {
        self.name = name
    }
    
}

// MARK: Property Parsing
extension RAML {
    
    internal func parseProperties(_ yaml: [Yaml: Yaml]) throws -> [Property] {
        var properties: [Property] = []
        for (key, value) in yaml {
            guard let keyString = key.string else { throw RAMLError.ramlParsingError(message: "Property key must be a string `\(key)`") }
            let property = parseProperty(name: keyString, yaml: value)
            properties.append(property)
        }
        return properties
    }
    
    private func parseProperty(name: String, yaml: Yaml) -> Property {
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
        
        return property
    }
    
}

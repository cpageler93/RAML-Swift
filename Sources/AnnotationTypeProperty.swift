//
//  AnnotationTypeProperty.swift
//  RAML
//
//  Created by Christoph on 30.06.17.
//

import Foundation
import Yaml

public class AnnotationTypeProperty {
    
    public var name: String
    public var `enum`: [String]?
    public var required: Bool?
    public var pattern: String?
    
    public init(name: String) {
        self.name = name
    }
    
}


// MARK: AnnotationTypeProperty Parsing
internal extension RAML {
    
    internal func parseAnnotationTypeProperties(yaml: Yaml?) throws -> [AnnotationTypeProperty]? {
        guard let yaml = yaml else { return nil }
        
        switch yaml {
        case .dictionary(let yamlDict):
            return try parseAnnotationTypeProperties(dict: yamlDict)
        default:
            return nil
        }
        
    }
    
    internal func parseAnnotationTypeProperties(dict: [Yaml: Yaml]) throws -> [AnnotationTypeProperty] {
        var annotationTypeProperties: [AnnotationTypeProperty] = []
        for (key, value) in dict {
            guard let keyString = key.string else {
                throw RAMLError.ramlParsingError(.invalidDataType(for: "Property Key Of AnnotationType",
                                                                  mustBeKindOf: "String"))
            }
            let annotationTypeProperty = try parseAnnotationTypeProperty(name: keyString, yaml: value)
            annotationTypeProperties.append(annotationTypeProperty)
        }
        return annotationTypeProperties
    }
    
    private func parseAnnotationTypeProperty(name: String, yaml: Yaml) throws -> AnnotationTypeProperty {
        let annotationType = AnnotationTypeProperty(name: name)
        
        if let enumArrayYaml = yaml["enum"].array {
            var enumValues: [String] = []
            for enumYaml in enumArrayYaml {
                guard let enumYamlString = enumYaml.string else {
                    throw RAMLError.ramlParsingError(.invalidDataType(for: "Enum Value in Annotation Type Property",
                                                                      mustBeKindOf: "String"))
                }
                enumValues.append(enumYamlString)
            }
            annotationType.enum = enumValues
        }
        
        annotationType.required = yaml["required"].bool
        annotationType.pattern = yaml["pattern"].string
        
        return annotationType
    }
    
}


public protocol HasAnnotationTypeProperties {
    
    var properties: [AnnotationTypeProperty]? { get set }
    
}


public extension HasAnnotationTypeProperties {
    
    public func propertyWith(name: String) -> AnnotationTypeProperty? {
        for property in properties ?? [] {
            if property.name == name {
                return property
            }
        }
        return nil
    }
    
}

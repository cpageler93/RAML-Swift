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
extension RAML {
    
    internal func parseAnnotationTypeProperties(_ yaml: [Yaml: Yaml]) throws -> [AnnotationTypeProperty] {
        var annotationTypeProperties: [AnnotationTypeProperty] = []
        for (key, value) in yaml {
            guard let keyString = key.string else { throw RAMLError.ramlParsingError(message: "property key of annotationType must be a string") }
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
                guard let enumYamlString = enumYaml.string else { throw RAMLError.ramlParsingError(message: "enum value in annotation type property must be a string") }
                enumValues.append(enumYamlString)
            }
            annotationType.enum = enumValues
        }
        
        if let requiredBool = yaml["required"].bool {
            annotationType.required = requiredBool
        }
        
        if let patternString = yaml["pattern"].string {
            annotationType.pattern = patternString
        }
        
        return annotationType
    }
    
}

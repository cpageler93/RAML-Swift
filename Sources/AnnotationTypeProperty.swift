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
    public var `enum`: StringEnum?
    public var required: Bool?
    public var pattern: String?
    
    public init(name: String) {
        self.name = name
    }
    
    internal init() {
        self.name = ""
    }
    
}


// MARK: AnnotationTypeProperty Parsing
internal extension RAML {
    
    internal func parseAnnotationTypeProperties(_ input: ParseInput) throws -> [AnnotationTypeProperty]? {
        guard let yaml = input.yaml else { return nil }
        
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
        
        annotationType.enum = try parseStringEnum(ParseInput(yaml["enum"]))
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


// MARK: Default Values
public extension AnnotationTypeProperty {
    
    public convenience init(initWithDefaultsBasedOn annotationTypeProperty: AnnotationTypeProperty) {
        self.init()
        
        self.name       = annotationTypeProperty.name
        self.enum       = annotationTypeProperty.enum
        self.required   = annotationTypeProperty.required
        self.pattern    = annotationTypeProperty.pattern
    }
    
    public func applyDefaults() -> AnnotationTypeProperty {
        return AnnotationTypeProperty(initWithDefaultsBasedOn: self)
    }
    
}

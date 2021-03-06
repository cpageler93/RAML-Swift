//
//  Annotation.swift
//  RAML
//
//  Created by Christoph on 30.06.17.
//

import Foundation
import Yaml

public class Annotation {
    
    public var name: String
    public var singleValue: String?
    public var parameters: [Yaml: Yaml]?
    
    public init(name: String) {
        self.name = name
    }
    
    internal init() {
        self.name = ""
    }
    
}


// MARK: Annotation Parsing
extension RAML {
    
    internal func parseAnnotations(_ input: ParseInput) throws -> [Annotation]? {
        guard let yaml = input.yaml else { return nil }
        
        switch yaml {
        case .dictionary(let yamlDict):
            return try parseAnnotations(dict: yamlDict)
        default:
            return nil
        }
        
    }
    
    internal func parseAnnotations(dict: [Yaml: Yaml]) throws -> [Annotation]? {
        var annotations: [Annotation] = []
        
        for (key, value) in dict {
            guard let keyString = key.string else {
                throw RAMLError.ramlParsingError(.invalidDataType(for: "Annotation Key",
                                                                  mustBeKindOf: "String"))
            }
            if keyString.isAnnotationKey() {
                let annotation = try parseAnnotation(name: keyString.annotationKeyName(), yaml: value)
                annotations.append(annotation)
            }
        }
        
        if annotations.count > 0 {
            return annotations
        } else {
            return nil
        }
    }
    
    internal func parseAnnotation(name: String, yaml: Yaml) throws -> Annotation{
        let annotation = Annotation(name: name)
        
        switch yaml {
        case .string(let yamlString):
            annotation.singleValue = yamlString
        case .dictionary(let yamlDict):
            annotation.parameters = yamlDict
        default:
            break
        }
        
        return annotation
    }
    
}


internal extension String {
    
    internal func isAnnotationKey() -> Bool {
        return self.hasPrefix("(") && self.hasSuffix(")")
    }
    
    internal func annotationKeyName() -> String {
        return String(self.dropFirst().dropLast())
    }
    
}


public protocol HasAnnotations {
    
    var annotations: [Annotation]? { get set }
    
}


public extension HasAnnotations {
    
    public func annotationWith(name: String) -> Annotation? {
        for annotation in annotations ?? [] {
            if annotation.name == name {
                return annotation
            }
        }
        return nil
    }
    
    public func hasAnnotationWith(name: String) -> Bool {
        return annotationWith(name: name) != nil
    }
    
}


// MARK: Default Values
public extension Annotation {
    
    public convenience init(initWithDefaultsBasedOn annotation: Annotation) {
        self.init()
        
        self.name           = annotation.name
        self.singleValue    = annotation.singleValue
        self.parameters     = annotation.parameters
    }
    
    public func applyDefaults() -> Annotation {
        return Annotation(initWithDefaultsBasedOn: self)
    }
    
}

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
    
    public init(name: String) {
        self.name = name
    }
}

// MARK: Annotation Parsing
extension RAML {
    
    internal func parseAnnotations(_ yaml: [Yaml: Yaml]) throws -> [Annotation]? {
        var annotations: [Annotation] = []
        
        for (key, value) in yaml {
            guard let keyString = key.string else { throw RAMLError.ramlParsingError(message: "annotation key must be a string") }
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
        return annotation
    }
    
}

extension String {
    
    public func isAnnotationKey() -> Bool {
        return self.hasPrefix("(") && self.hasSuffix(")")
    }
    
    public func annotationKeyName() -> String {
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

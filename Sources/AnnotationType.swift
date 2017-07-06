//
//  AnnotationType.swift
//  RAML
//
//  Created by Christoph on 30.06.17.
//

import Foundation
import Yaml

public enum AnnotationTypeEnum: Equatable {
    case `nil`
    case string
    case properties
    case multiple(of: [AnnotationTypeEnum])
}

public func ==(lhs: AnnotationTypeEnum, rhs: AnnotationTypeEnum) -> Bool {
    switch (lhs, rhs) {
    case (.nil, .nil): return true
    case (.string, .string): return true
    case (.properties, .properties): return true
    case (.multiple(of: let a), .multiple(of: let b)): return a == b
    default: return false
    }
}


public class AnnotationType: HasAnnotationTypeProperties {
    
    public var name: String
    public var type = AnnotationTypeEnum.string
    public var properties: [AnnotationTypeProperty]?
    
    public init(name: String) {
        self.name = name
    }
}


// MARK: AnnotationTypes Parsing
extension RAML {
    
    internal func parseAnnotationTypes(_ yaml: [Yaml: Yaml]) throws -> [AnnotationType] {
        var annotationTypes: [AnnotationType] = []
        for (key, value) in yaml {
            guard let keyString = key.string else {
                throw RAMLError.ramlParsingError(.invalidDataType(for: "AnnotationType Key",
                                                                  mustBeKindOf: "String"))
            }
            let annotationType = try parseAnnotationType(name: keyString, yaml: value)
            annotationTypes.append(annotationType)
        }
        return annotationTypes
    }
    
    private func parseAnnotationType(name: String, yaml: Yaml) throws -> AnnotationType {
        let annotationType = AnnotationType(name: name)
        
        if let yamlString = yaml.string {
            annotationType.type = try typeFromString(yamlString)
        } else if let yamlDictionary = yaml.dictionary {
            if let typeString = yamlDictionary["type"]?.string {
                annotationType.type = try typeFromString(typeString)
            }
            
            if let yamlPropertiesDictionary = yamlDictionary["properties"]?.dictionary {
                annotationType.type = .properties
                annotationType.properties = try parseAnnotationTypeProperties(yamlPropertiesDictionary)
            }
        }
        
        return annotationType
    }
    
    private func typeFromString(_ string: String) throws -> AnnotationTypeEnum {
        if string == "nil" {
            return .nil
        } else if string == "string" {
            return .string
        } else if string == "string?" {
            return .multiple(of: [.string, .nil])
        } else if string.contains("|") {
            // multiple types
            let stringTypes = string.replacingOccurrences(of: " ", with: "").components(separatedBy: "|")
            var types: [AnnotationTypeEnum] = []
            for stringType in stringTypes {
                types.append(try typeFromString(stringType))
            }
            return .multiple(of: types)
        }
        throw RAMLError.ramlParsingError(.invalidAnnotationType(string))
    }
    
}

public protocol HasAnnotationTypes {
    var annotationTypes: [AnnotationType]? { get set }
}

extension HasAnnotationTypes {
    
    public func annotationTypeWith(name: String) -> AnnotationType? {
        for annotationType in annotationTypes ?? [] {
            if annotationType.name == name {
                return annotationType
            }
        }
        return nil
    }
    
    public func hasAnnotationTypeWith(name: String) -> Bool {
        return annotationTypeWith(name: name) != nil
    }
    
}

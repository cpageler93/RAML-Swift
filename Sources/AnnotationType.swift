//
//  AnnotationType.swift
//  RAML
//
//  Created by Christoph on 30.06.17.
//

import Foundation
import Yaml
import PathKit

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


public class AnnotationType: HasAnnotationTypeProperties, HasAnnotations {
    
    public var name: String
    public var displayName: String?
    public var type: AnnotationTypeEnum?
    public var properties: [AnnotationTypeProperty]?
    public var annotations: [Annotation]?
    
    public init(name: String) {
        self.name = name
    }
    
    internal init() {
        self.name = ""
    }
    
}


// MARK: AnnotationTypes Parsing
internal extension RAML {
    
    internal func parseAnnotationTypes(_ input: ParseInput) throws -> [AnnotationType]? {
        guard let yaml = input.yaml else { return nil }
        
        switch yaml {
        case .dictionary(let yamlDict):
            return try parseAnnotationTypes(dict: yamlDict, parentFilePath: input.parentFilePath)
        default:
            return nil
        }
        
        // TODO: Consider Includes
    }
    
    private func parseAnnotationTypes(dict: [Yaml: Yaml], parentFilePath: Path?) throws -> [AnnotationType] {
        var annotationTypes: [AnnotationType] = []
        for (key, value) in dict {
            guard let keyString = key.string else {
                throw RAMLError.ramlParsingError(.invalidDataType(for: "AnnotationType Key",
                                                                  mustBeKindOf: "String"))
            }
            let annotationType = try parseAnnotationType(name: keyString, yaml: value, parentFilePath: parentFilePath)
            annotationTypes.append(annotationType)
        }
        return annotationTypes
    }
    
    private func parseAnnotationType(name: String, yaml: Yaml, parentFilePath: Path?) throws -> AnnotationType {
        let annotationType = AnnotationType(name: name)
        
        switch yaml {
        case .string(let yamlString):
            annotationType.type         = try typeFromString(yamlString)
        case .dictionary(let yamlDict):
            annotationType.displayName  = yamlDict["displayName"]?.string
            annotationType.type         = try typeFromString(yamlDict["type"]?.string)
            annotationType.properties   = try parseAnnotationTypeProperties(ParseInput(yamlDict["properties"], parentFilePath))
            annotationType.annotations  = try parseAnnotations(ParseInput(yaml, parentFilePath))
        case .null:
            break
        default:
            throw RAMLError.ramlParsingError(.failedParsingAnnotationType)
        }
        
        return annotationType
    }
    
    private func typeFromString(_ string: String?) throws -> AnnotationTypeEnum? {
        guard let string = string else { return nil }
        
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
                guard let type = try typeFromString(stringType) else { continue }
                types.append(type)
            }
            return .multiple(of: types)
        }
        throw RAMLError.ramlParsingError(.invalidAnnotationType(string))
    }
    
}


public protocol HasAnnotationTypes {
    
    var annotationTypes: [AnnotationType]? { get set }
    
}


public extension HasAnnotationTypes {
    
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


// MARK: Default Values
public extension AnnotationType {
    
    public convenience init(initWithDefaultsBasedOn annotationType: AnnotationType) {
        self.init()
        
        self.name           = annotationType.name
        self.displayName    = annotationType.displayName ?? annotationType.name
        self.type           = annotationType.type ?? AnnotationTypeEnum.string
        self.properties     = annotationType.properties?.map { $0.applyDefaults() }
        self.annotations    = annotationType.annotations?.map { $0.applyDefaults() }
    }
    
    public func applyDefaults() -> AnnotationType {
        return AnnotationType(initWithDefaultsBasedOn: self)
    }
    
}

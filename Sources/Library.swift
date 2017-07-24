//
//  Library.swift
//  RAML
//
//  Created by Christoph Pageler on 12.07.17.
//

import Foundation
import Yaml
import PathKit

public class Library: HasTypes, HasResourceTypes, HasTraitDefinitions, HasSecuritySchemes, HasAnnotationTypes, HasAnnotations, HasLibraries {
    
    public var identifier: String
    public var usage: String?
    
    public var types: [Type]?
    public var resourceTypes: [ResourceType]?
    public var traitDefinitions: [TraitDefinition]?
    public var securitySchemes: [SecurityScheme]?
    public var annotationTypes: [AnnotationType]?
    public var annotations: [Annotation]?
    public var uses: [Library]?
    
    public init(identifier: String) {
        self.identifier = identifier
    }
    
    internal init() {
        self.identifier = ""
    }
    
}


// MARK: Parsing Libraries
internal extension RAML {
    
    internal func parseLibraries(_ input: ParseInput) throws -> [Library]? {
        guard let yaml = input.yaml else { return nil }
        
        switch yaml {
        case .dictionary(let yamlDict):
            return try parseLibraries(dict: yamlDict, parentFilePath: input.parentFilePath)
        default:
            return nil
        }
        
    }
    
    private func parseLibraries(dict: [Yaml: Yaml], parentFilePath: Path?) throws -> [Library] {
        var libraries: [Library] = []
        for (key, value) in dict {
            guard let keyString = key.string else {
                throw RAMLError.ramlParsingError(.invalidDataType(for: "Library Key",
                                                                  mustBeKindOf: "String"))
            }
            let library = try parseLibrary(identifier: keyString, yaml: value, parentFilePath: parentFilePath)
            libraries.append(library)
        }
        return libraries
    }
    
    private func parseLibrary(identifier: String, yaml: Yaml, parentFilePath: Path?) throws -> Library {
        let library = Library(identifier: identifier)
        
        switch yaml {
        case .dictionary(let yamlDict):
            library.usage               = yamlDict["usage"]?.string
            library.types               = try parseTypes(ParseInput(yamlDict["types"], parentFilePath))
            library.resourceTypes       = try parseResourceTypes(ParseInput(yamlDict["resourceTypes"], parentFilePath))
            library.traitDefinitions    = try parseTraitDefinitions(ParseInput(yamlDict["traits"], parentFilePath))
            library.securitySchemes     = try parseSecuritySchemes(ParseInput(yamlDict["securitySchemes"], parentFilePath))
            library.annotationTypes     = try parseAnnotationTypes(ParseInput(yamlDict["annotationTypes"], parentFilePath))
            library.annotations         = try parseAnnotations(ParseInput(yaml, parentFilePath))
            library.uses                = try parseLibraries(ParseInput(yamlDict["uses"], parentFilePath))
        case .string(let yamlString):
            let (yamlFromInclude, path) = try parseLibraryFromIncludeString("!include \(yamlString)", parentFilePath: parentFilePath)
            return try parseLibrary(identifier: identifier, yaml: yamlFromInclude, parentFilePath: path)
        default:
            throw RAMLError.ramlParsingError(.failedParsingLibrary)
        }
        
        return library
    }
    
    private func parseLibraryFromIncludeString(_ includeString: String, parentFilePath: Path?) throws -> (Yaml, Path) {
        return try parseYamlFromIncludeString(includeString, parentFilePath: parentFilePath, permittedFragmentIdentifier: "Library")
    }
    
}


public protocol HasLibraries {
    
    var uses: [Library]? { get set }
    
}


public extension HasLibraries {
    
    public func libraryWith(identifier: String) -> Library? {
        for library in uses ?? [] {
            if library.identifier == identifier {
                return library
            }
        }
        return nil
    }
    
    public func hasLibraryWith(identifier: String) -> Bool {
        return libraryWith(identifier: identifier) != nil
    }
    
}


// MARK: Default Values
public extension Library {
    
    public convenience init(initWithDefaultsBasedOn library: Library, raml: RAML) {
        self.init()
        
        self.identifier = library.identifier
        self.usage = library.usage
        
        self.types = library.types?.map { $0.applyDefaults() }
        self.resourceTypes = library.resourceTypes?.map { $0.applyDefaults(raml: raml) }
        self.traitDefinitions = library.traitDefinitions?.map { $0.applyDefaults() }
        self.securitySchemes = library.securitySchemes?.map { $0.applyDefaults(raml: raml) }
        self.annotationTypes = library.annotationTypes?.map { $0.applyDefaults() }
        self.annotations = library.annotations?.map { $0.applyDefaults() }
        self.uses = library.uses?.map { $0.applyDefaults(raml: raml) }
    }
    
    public func applyDefaults(raml: RAML) -> Library {
        return Library(initWithDefaultsBasedOn: self, raml: raml)
    }
    
}

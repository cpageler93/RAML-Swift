//
//  Library.swift
//  RAML
//
//  Created by Christoph Pageler on 12.07.17.
//

import Foundation
import Yaml

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
    
}


// MARK: Parsing Libraries
internal extension RAML {
    
    internal func parseLibraries(_ input: ParseInput) throws -> [Library]? {
        guard let yaml = input.yaml else { return nil }
        
        switch yaml {
        case .dictionary(let yamlDict):
            return try parseLibraries(dict: yamlDict)
        default:
            return nil
        }
        
    }
    
    private func parseLibraries(dict: [Yaml: Yaml]) throws -> [Library] {
        var libraries: [Library] = []
        for (key, value) in dict {
            guard let keyString = key.string else {
                throw RAMLError.ramlParsingError(.invalidDataType(for: "Library Key",
                                                                  mustBeKindOf: "String"))
            }
            let library = try parseLibrary(identifier: keyString, yaml: value)
            libraries.append(library)
        }
        return libraries
    }
    
    private func parseLibrary(identifier: String, yaml: Yaml) throws -> Library {
        let library = Library(identifier: identifier)
        
        switch yaml {
        case .dictionary(let yamlDict):
            library.usage               = yamlDict["usage"]?.string
            library.types               = try parseTypes(yaml: yamlDict["types"])
            library.resourceTypes       = try parseResourceTypes(yaml: yamlDict["resourceTypes"])
            library.traitDefinitions    = try parseTraitDefinitions(yaml: yamlDict["traits"])
            library.securitySchemes     = try parseSecuritySchemes(yaml: yamlDict["securitySchemes"])
            library.annotationTypes     = try parseAnnotationTypes(yaml: yamlDict["annotationTypes"])
            library.annotations         = try parseAnnotations(yaml: yaml)
            library.uses                = try parseLibraries(yaml: yamlDict["uses"])
        case .string(let yamlString):
            let yamlFromInclude = try parseLibraryFromIncludeString("!include \(yamlString)")
            return try parseLibrary(identifier: identifier,
                                    yaml: yamlFromInclude)
        default:
            throw RAMLError.ramlParsingError(.failedParsingLibrary)
        }
        
        return library
    }
    
    private func parseLibraryFromIncludeString(_ includeString: String) throws -> Yaml {
        try testInclude(includeString)
        return try parseYamlFromIncludeString(includeString,
                                              parentFilePath: try directoryOfInitialFilePath(),
                                              permittedFragmentIdentifier: "Library")
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

//
//  RAML+DocumentationEntry.swift
//  RAML
//
//  Created by Christoph Pageler on 24.06.17.
//

import Foundation
import Yaml
import PathKit

public class DocumentationEntry: HasAnnotations {
    
    public var title: String
    public var content: String
    public var annotations: [Annotation]?
    
    public init(title: String, content: String) {
        self.title = title
        self.content = content
    }
    
    internal init() {
        self.title = ""
        self.content = ""
    }
}


// MARK: Documentation Parsing
internal extension RAML {
    
    internal func parseDocumentation(_ input: ParseInput) throws -> [DocumentationEntry]? {
        guard let yaml = input.yaml else { return nil }
        
        switch yaml {
        case .array(let yamlArray):
            return try parseDocumentation(array: yamlArray, parentFilePath: input.parentFilePath)
        default: return nil
        }
        // TODO: Consider Includes
    }
    
    private func parseDocumentation(array: [Yaml], parentFilePath: Path?) throws -> [DocumentationEntry] {
        var documentation: [DocumentationEntry] = []
        
        for yamlDocumentationEntry in array {
            guard let title = yamlDocumentationEntry["title"].string else {
                throw RAMLError.ramlParsingError(.missingValueFor(key: "title"))
            }
            guard var content = yamlDocumentationEntry["content"].string else {
                throw RAMLError.ramlParsingError(.missingValueFor(key: "content"))
            }
            
            if isInclude(content) {
                try testInclude(content)
                guard let parentFilePath = parentFilePath else {
                    throw RAMLError.ramlParsingError(.invalidInclude)
                }
                content = try contentFromIncludeString(content, parentFilePath: parentFilePath)
            }
            
            let documentationEntry = DocumentationEntry(title: title, content: content)
            documentationEntry.annotations = try parseAnnotations(ParseInput(yamlDocumentationEntry, parentFilePath))
            documentation.append(documentationEntry)
        }
        return documentation
    }
    
}

public protocol HasDocumentationEntries {
    
    var documentation: [DocumentationEntry]? { get set }
    
}

public extension HasDocumentationEntries {
    
    func documentationEntryWith(title: String) -> DocumentationEntry? {
        for documentationEntry in documentation ?? [] {
            if documentationEntry.title == title {
                return documentationEntry
            }
        }
        return nil
    }
    
    func hasDocumentationEntryWith(title: String) -> Bool {
        return documentationEntryWith(title: title) != nil
    }
    
}


// MARK: Default Values
public extension DocumentationEntry {
    
    public convenience init(initWithDefaultsBasedOn documentationEntry: DocumentationEntry) {
        self.init()
        
        self.title          = documentationEntry.title
        self.content        = documentationEntry.content
        self.annotations    = documentationEntry.annotations?.map { $0.applyDefaults() }
    }
    
    public func applyDefaults() -> DocumentationEntry {
        return DocumentationEntry(initWithDefaultsBasedOn: self)
    }
    
}

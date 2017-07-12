//
//  RAML+DocumentationEntry.swift
//  RAML
//
//  Created by Christoph Pageler on 24.06.17.
//

import Foundation
import Yaml

public class DocumentationEntry {
    
    public var title: String
    public var content: String
    
    public init(title: String, content: String) {
        self.title = title
        self.content = content
    }
    
}


// MARK: Documentation Parsing
internal extension RAML {
    
    internal func parseDocumentation(yaml: Yaml?) throws -> [DocumentationEntry]? {
        guard let yaml = yaml else { return nil }
        
        switch yaml {
        case .array(let yamlArray):
            return try parseDocumentation(array: yamlArray)
        default: return nil
        }
        // TODO: Consider Includes
        
        return nil
    }
    
    internal func parseDocumentation(array: [Yaml]) throws -> [DocumentationEntry] {
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
                content = try contentFromIncludeString(content, parentFilePath: try directoryOfInitialFilePath())
            }
            
            let documentationEntry = DocumentationEntry(title: title, content: content)
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

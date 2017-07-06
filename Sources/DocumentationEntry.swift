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
extension RAML {
    
    internal func parseDocumentation(_ yaml: [Yaml]) throws -> [DocumentationEntry] {
        var documentation: [DocumentationEntry] = []
        
        for (_, yamlDocumentationEntry) in yaml.enumerated() {
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

protocol HasDocumentationEntries {
    var documentation: [DocumentationEntry]? { get set }
}

extension HasDocumentationEntries {
    
    func documentationWithTitle(_ title: String) -> DocumentationEntry? {
        for documentationEntry in documentation ?? [] {
            if documentationEntry.title == title {
                return documentationEntry
            }
        }
        return nil
    }
    
}

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
    
    init(title: String, content: String) {
        self.title = title
        self.content = content
    }
}


// MARK: Documentation Parsing
extension RAML {
    
    internal func parseDocumentation(_ yaml: [Yaml]) throws -> [DocumentationEntry] {
        var documentation: [DocumentationEntry] = []
        
        for (index, yamlDocumentationEntry) in yaml.enumerated() {
            guard let title = yamlDocumentationEntry["title"].string else {
                throw RAMLError.ramlParsingError(message: "`title` not set in documentation entry \(index)")
            }
            guard let content = yamlDocumentationEntry["content"].string else {
                throw RAMLError.ramlParsingError(message: "`content` not set in documentation entry \(index)")
            }
            let documentationEntry = DocumentationEntry(title: title, content: content)
            documentation.append(documentationEntry)
        }
        
        return documentation
    }
    
}

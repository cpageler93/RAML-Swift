//
//  RAML+Include.swift
//  RAML
//
//  Created by Christoph Pageler on 24.06.17.
//

import Foundation
import PathKit
import Yaml

internal extension RAML {
    
    internal func isInclude(_ value: String) -> Bool {
        return value.hasPrefix("!include")
    }
    
    internal func testInclude(_ value: String) throws {
        if isInclude(value) && !includesAvailable {
            throw RAMLError.ramlParsingError(.includesNotAvailable)
        }
    }
    
    internal func parseYamlFromIncludeString(_ string: String,
                                             parentFilePath: Path?,
                                             permittedFragmentIdentifier: String) throws -> (Yaml, Path) {
        guard let parentFilePath = parentFilePath else {
            throw RAMLError.ramlParsingError(.invalidInclude)
        }
        
        let absolutePath = absolutePathFromIncludeString(string, parentFilePath: parentFilePath)
        let content = try contentFromIncludeString(string, parentFilePath: parentFilePath)
        try validateRamlFragmentIdentifier(permittedFragmentIdentifier, inString: content)
        
        return try (yamlFromString(content), absolutePath)
    }
    
    internal func absolutePathFromIncludeString(_ string: String, parentFilePath: Path) -> Path {
        let pathString = string.replacingOccurrences(of: "!include ", with: "")
        return parentFilePath.directory() + Path(pathString)
    }
    
    internal func contentFromIncludeString(_ string: String,
                                           parentFilePath: Path) throws -> String {
        guard isInclude(string) else { throw RAMLError.ramlParsingError(.stringWhichIsParsedAsIncludeIsNotInclude) }
        try testInclude(string)
        
        let absolutePath = absolutePathFromIncludeString(string, parentFilePath: parentFilePath)
        
        return try contentFromFile(path: absolutePath)
    }
    
}


internal extension Path {
    
    internal func directory() -> Path {
        if isDirectory {
            return self
        }
        return parent().absolute()
    }
    
}

internal struct ParseInput {
    
    let yaml: Yaml?
    let parentFilePath: Path?
    
    internal init(_ yaml: Yaml?, _ parentFilePath: Path?) {
        self.yaml = yaml
        self.parentFilePath = parentFilePath
    }
    
}

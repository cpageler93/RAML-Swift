//
//  RAML+Include.swift
//  RAML
//
//  Created by Christoph Pageler on 24.06.17.
//

import Foundation
import PathKit
import Yaml

extension RAML {
    
    internal func isInclude(_ value: String) -> Bool {
        return value.hasPrefix("!include")
    }
    
    internal func testInclude(_ value: String) throws {
        if isInclude(value) && !includesAvailable {
            throw RAMLError.ramlParsingError(error: .includesNotAvailable)
        }
    }
    
    internal func parseYamlFromIncludeString(_ string: String,
                                             parentFilePath: Path,
                                             permittedFragmentIdentifier: String) throws -> Yaml {
        let content = try contentFromIncludeString(string, parentFilePath: parentFilePath)
        try validateRamlFragmentIdentifier(permittedFragmentIdentifier, inString: content)
        
        return try yamlFromString(content)
    }
    
    internal func contentFromIncludeString(_ string: String,
                                           parentFilePath: Path) throws -> String {
        guard isInclude(string) else { throw RAMLError.ramlParsingError(error: .stringWhichIsParsedAsIncludeIsNotInclude) }
        try testInclude(string)
        
        let pathString = string.replacingOccurrences(of: "!include ", with: "")
        let absolutePath = parentFilePath.directory() + Path(pathString)
        
        return try contentFromFile(path: absolutePath)
    }
    
}

extension Path {
    
    public func directory() -> Path {
        if isDirectory {
            return self
        }
        return parent().absolute()
    }
    
}

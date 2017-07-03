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
            throw RAMLError.ramlParsingError(message: "Includes not available at `\(value)`")
        }
    }
    
    internal func parseYamlFromIncludeString(_ string: String,
                                             parentFilePath: Path) throws -> Yaml {
        guard isInclude(string) else { throw RAMLError.ramlParsingError(message: "string parsed as include is not an include `\(string)`") }
        
        let pathString = string.replacingOccurrences(of: "!include ", with: "")
        let absolutePath = parentFilePath.directory() + Path(pathString)
        
        let content = try contentFromFile(path: absolutePath)
        return try yamlFromString(content)
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

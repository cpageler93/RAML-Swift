//
//  RAML+Include.swift
//  RAML
//
//  Created by Christoph Pageler on 24.06.17.
//

import Foundation

extension RAML {
    
    internal func isInclude(_ value: String) -> Bool {
        return value.hasPrefix("!include")
    }
    
    internal func testInclude(_ value: String) throws {
        if isInclude(value) && !includesAvailable {
            throw RAMLError.ramlParsingError(message: "Includes not available at `\(value)`")
        }
    }
    
}

//
//  RAMLError.swift
//  RAML
//
//  Created by Christoph Pageler on 24.06.17.
//

import Foundation

enum RAMLError: Error {
    case yamlParsingError(message: String)
    case invalidRAMLVersion(message: String)
    case ramlParsingError(message: String)
}

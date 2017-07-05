//
//  RAMLError.swift
//  RAML
//
//  Created by Christoph Pageler on 24.06.17.
//

import Foundation

public enum RAMLError: Error {
    case yamlParsingError(error: YAMLParsingError)
    case ramlParsingError(error: RAMLParsingError)
}

public enum RAMLParsingError: Error {
    case missingValueFor(key: String)
    case invalidDataType(for: String, mustBeKindOf: String)
    case invalidProtocol(String)
    case includesNotAvailable
    case stringWhichIsParsedAsIncludeIsNotInclude
    case invalidFile
    case missingFragmentIdentifier
    case invalidFragmentIdentifier(invalid: String, valid: String)
    case stringIsEmpty
    case invalidVersion
}


public enum YAMLParsingError: Error {
    case invalidFile(atPath: String)
    case error(Error)
}

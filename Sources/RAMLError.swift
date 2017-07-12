//
//  RAMLError.swift
//  RAML
//
//  Created by Christoph Pageler on 24.06.17.
//

import Foundation

public enum RAMLError: Error, Equatable {
    
    case yamlParsingError(Error)
    case ramlParsingError(RAMLParsingError)
    case invalidFile(atPath: String)
    case unknown
    
}


public func ==(lhs: RAMLError, rhs: RAMLError) -> Bool {
    switch (lhs, rhs) {
    case (let .yamlParsingError(lhsError), let .yamlParsingError(rhsError)): return lhsError.localizedDescription == rhsError.localizedDescription
    case (let .ramlParsingError(lhsError), let .ramlParsingError(rhsError)): return lhsError == rhsError
    case (let .invalidFile(lhsPath), let .invalidFile(rhsPath)): return lhsPath == rhsPath
    case (.unknown, .unknown): return true
    default: return false
    }
}


public enum RAMLParsingError: Error {
    
    case missingValueFor(key: String)
    case missingFragmentIdentifier
    
    case includesNotAvailable
    case settingsNotAvailableFor(String)
    
    case stringWhichIsParsedAsIncludeIsNotInclude
    case stringIsEmpty
    
    case invalidDataType(for: String, mustBeKindOf: String)
    case invalidProtocol(String)
    case invalidFragmentIdentifier(invalid: String, valid: String)
    case invalidFile
    case invalidVersion
    case invalidInclude
    case invalidAnnotationType(String)
    case invalidHeaderType(String)
    case invalidSecuritySchemeType(String)
    
    case failedParsingTraitUsage
    case failedParsingTraitDefinition
    case failedParsingSecurityScheme
    case failedParsingAnnotationType
    case failedParsingResourceType
    
}


public func ==(lhs: RAMLParsingError, rhs: RAMLParsingError) -> Bool {
    switch (lhs, rhs) {
    case (.missingValueFor(key: let lhsKey), .missingValueFor(key: let rhsKey)): return lhsKey == rhsKey
    case (.missingFragmentIdentifier, .missingFragmentIdentifier): return true
        
    case (.includesNotAvailable, .includesNotAvailable): return true
    case (.settingsNotAvailableFor(let lhsString), .settingsNotAvailableFor(let rhsString)): return lhsString == rhsString
        
    case (.stringWhichIsParsedAsIncludeIsNotInclude, .stringWhichIsParsedAsIncludeIsNotInclude): return true
    case (.stringIsEmpty, .stringIsEmpty): return true
        
    case (.invalidDataType(for: let lhsFor,
                           mustBeKindOf: let lhsMustBeKindOf),
          .invalidDataType(for: let rhsFor,
                           mustBeKindOf: let rhsMustBeKindOf)):
        return lhsFor == rhsFor && lhsMustBeKindOf == rhsMustBeKindOf
    case (.invalidProtocol(let lhsProtocol), .invalidProtocol(let rhsProtocol)): return lhsProtocol == rhsProtocol
    case (.invalidFragmentIdentifier(invalid: let lhsInvalid,
                                     valid: let lhsValid),
          .invalidFragmentIdentifier(invalid: let rhsInvalid,
                                     valid: let rhsValid)):
        return lhsInvalid == rhsInvalid && lhsValid == rhsValid
    case (.invalidFile, .invalidFile): return true
    case (.invalidVersion, .invalidVersion): return true
    case (.invalidInclude, .invalidInclude): return true
    case (.invalidAnnotationType(let lhsString), .invalidAnnotationType(let rhsString)): return lhsString == rhsString
    case (.invalidHeaderType(let lhsString), .invalidHeaderType(let rhsString)): return lhsString == rhsString
    case (.invalidSecuritySchemeType(let lhsString), .invalidSecuritySchemeType(let rhsString)): return lhsString == rhsString
        
    case (.failedParsingTraitUsage, .failedParsingTraitUsage): return true
    case (.failedParsingTraitDefinition, .failedParsingTraitDefinition): return true
    case (.failedParsingSecurityScheme, .failedParsingSecurityScheme): return true
    case (.failedParsingAnnotationType, .failedParsingAnnotationType): return true
    case (.failedParsingResourceType, .failedParsingResourceType): return true
    
    default: return false
    }
}


public enum YAMLParsingError: Error {
    
    case error(Error)
    
}

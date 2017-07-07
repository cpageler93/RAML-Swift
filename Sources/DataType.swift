//
//  DataType.swift
//  RAML
//
//  Created by Christoph Pageler on 24.06.17.
//

import Foundation

public indirect enum DataType: Equatable {
    
    public enum ScalarType: String {
        case number
        case boolean
        case string
        case dateOnly
        case timeOnly
        case dateTimeOnly
        case dateTime
        case file
        case integer
        case `nil`
    }
    
    case any
    case object
    case array(ofType: DataType)
    case union(types: [DataType])
    case scalar(type: ScalarType)
    case custom(type: String)
    
    public static func dataTypeEnumFrom(string: String) -> DataType {
        if string == "object" {
            return .object
        } else if string.hasSuffix("[]") {
            let arrayType = String(string.dropLast(2))
            return .array(ofType: dataTypeEnumFrom(string: arrayType))
        } else if let scalar = ScalarType(rawValue: string) {
            return .scalar(type: scalar)
        }
        return .custom(type: string)
    }

}


public func ==(lhs: DataType, rhs: DataType) -> Bool {
    switch (lhs, rhs) {
    case (.any, .any): return true
    case (.object, .object): return true
    case let (.array(ofType: a), .array(ofType: b)): return a == b
    case let (.union(types: a), .union(types: b)): return a == b
    case let (.scalar(type: a), .scalar(type: b)): return a == b
    case let (.custom(type: a), .custom(type: b)): return a == b
    default: return false
    }
}

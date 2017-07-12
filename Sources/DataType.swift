//
//  DataType.swift
//  RAML
//
//  Created by Christoph Pageler on 24.06.17.
//

import Foundation
import Yaml

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
    
    public static func dataTypeEnumFrom(yaml: Yaml, dictKey: String? = nil) throws -> DataType? {
        
        switch yaml {
        case .dictionary(let yamlDict):
            guard let dictKey = dictKey else { throw RAMLError.unknown }
            for (key, value) in yamlDict {
                if let keyString = key.string, keyString == dictKey {
                    return try dataTypeEnumFrom(yaml: value)
                }
            }
            return nil
        case .string(let yamlString):
            return DataType.dataTypeEnumFrom(string: yamlString)
        case .null:
            return nil
        default:
            break
        }
        
        throw RAMLError.unknown
    }
    
    public static func dataTypeEnumFrom(string: String) -> DataType {
        if string == "object" {
            return .object
        } else if string.hasSuffix("[]") {
            let arrayType = String(string.dropLast(2))
            return .array(ofType: dataTypeEnumFrom(string: arrayType))
        } else if let scalar = ScalarType(rawValue: string) {
            return .scalar(type: scalar)
        } else if string.contains("|") {
            let stringTypes = string
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "(", with: "")
                .replacingOccurrences(of: ")", with: "")
                .components(separatedBy: "|")
            var types: [DataType] = []
            for stringType in stringTypes {
                types.append(dataTypeEnumFrom(string: stringType))
            }
            return .union(types: types)
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

//
//  DataType.swift
//  RAML
//
//  Created by Christoph Pageler on 24.06.17.
//

import Foundation

public indirect enum DataType {
    
    public enum ScalarType {
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
}

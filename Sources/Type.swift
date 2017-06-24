//
//  Type.swift
//  RAML
//
//  Created by Christoph Pageler on 24.06.17.
//

import Foundation

public class Type {
    
    public enum `Type` {
        
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
        case array
        case union(types: [Type])
        case scalar(type: ScalarType)
        case custom(type: String)
    }
    
    public var name: String
    // default?
    public var type: Type?
    // example?
    // examples?
    // displayName?
    // description?
    // annotations?
    // facets?
    // xml?
    // enum?
    
    // MARK: Object Type
    
    // properties?
    // minProperties?
    // maxProperties?
    // additionalProperties?
    // discriminator?
    // discriminatorValue?
    
    init(name: String) {
        self.name = name
        
    }
    
}

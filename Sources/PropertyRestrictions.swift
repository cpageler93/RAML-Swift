//
//  PropertyRestrictions.swift
//  RAML
//
//  Created by Christoph Pageler on 26.06.17.
//

import Foundation

public protocol PropertyRestrictions { }


public class StringRestrictions: PropertyRestrictions {
    
    public var pattern: String?
    public var minLength: Int?
    public var maxLength: Int?
    
}


public class NumberRestrictions: PropertyRestrictions {
    
    public enum NumberRestrictionFormat: String {
        case int8
        case int16
        case int32
        case int64
        case int
        case long
        case float
        case double
    }
    
    public var minimum: Int?
    public var maximum: Int?
    public var format: NumberRestrictionFormat?
    public var multipleOf: Int?
    
}


public class FileRestrictions: PropertyRestrictions, HasFileTypes {
    
    public var fileTypes: [MediaType]?
    public var minLength: Int?
    public var maxLength: Int?
    
}

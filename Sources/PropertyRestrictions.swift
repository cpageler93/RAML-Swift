//
//  PropertyRestrictions.swift
//  RAML
//
//  Created by Christoph Pageler on 26.06.17.
//

import Foundation
import Yaml

public protocol PropertyRestrictions {
    
    func applyDefaults() -> PropertyRestrictions
    
}


public class StringRestrictions: PropertyRestrictions {
    
    public var pattern: String?
    public var minLength: Int?
    public var maxLength: Int?
    
    public convenience init(initWithDefaultsBasedOn stringRestrictions: StringRestrictions) {
        self.init()
        
        self.pattern    = stringRestrictions.pattern
        self.minLength  = stringRestrictions.minLength ?? 0
        self.maxLength  = stringRestrictions.maxLength ?? 2147483647
    }
    
    public func applyDefaults() -> PropertyRestrictions {
        return StringRestrictions(initWithDefaultsBasedOn: self)
    }
    
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
    
    public convenience init(initWithDefaultsBasedOn numberRestrictions: NumberRestrictions) {
        self.init()
        
        self.minimum    = numberRestrictions.minimum
        self.maximum    = numberRestrictions.maximum
        self.format     = numberRestrictions.format
        self.multipleOf = numberRestrictions.multipleOf
    }
    
    public func applyDefaults() -> PropertyRestrictions {
        return NumberRestrictions(initWithDefaultsBasedOn: self)
    }
}


public class FileRestrictions: PropertyRestrictions, HasFileTypes {
    
    public var fileTypes: [MediaType]?
    public var minLength: Int?
    public var maxLength: Int?
    
    public convenience init(initWithDefaultsBasedOn fileRestrictions: FileRestrictions) {
        self.init()
        
        self.fileTypes = fileRestrictions.fileTypes?.map { $0.applyDefaults() }
        self.minLength = fileRestrictions.minLength ?? 0
        self.maxLength = fileRestrictions.maxLength ?? 2147483647
    }
    
    public func applyDefaults() -> PropertyRestrictions {
        return FileRestrictions(initWithDefaultsBasedOn: self)
    }
}


internal extension RAML {
    
    internal static func propertyRestrictionsFor(type: DataType) -> PropertyRestrictions? {
        switch type {
        case .scalar(type: let scalarType):
            switch scalarType {
            case .string: return StringRestrictions()
            case .number: return NumberRestrictions()
            case .file: return FileRestrictions()
            default: return nil
            }
        default:
            return nil
        }
    }
    
    internal func parseRestrictions(forType dataType: DataType?, yaml: Yaml) throws -> PropertyRestrictions? {
        guard let dataType = dataType else { return nil }
        switch dataType {
        case .scalar(type: let scalarType):
            switch scalarType {
            case .string: return try parseStringRestrictions(yaml)
            case .number: return try parseNumberRestrictions(yaml)
            case .file: return try parseFileRestrictions(yaml)
            default: return nil
            }
        default:
            return nil
        }
    }
    
    private func parseStringRestrictions(_ yaml: Yaml) throws -> StringRestrictions? {
        let restrictions = StringRestrictions()
        
        restrictions.pattern    = yaml["pattern"].string
        restrictions.minLength  = yaml["minLength"].int
        restrictions.maxLength  = yaml["maxLength"].int
        
        return restrictions
    }
    
    private func parseNumberRestrictions(_ yaml: Yaml) throws -> NumberRestrictions? {
        let restrictions = NumberRestrictions()
        
        restrictions.minimum    = yaml["minimum"].int
        restrictions.maximum    = yaml["maximum"].int
        if let formatString     = yaml["format"].string {
            restrictions.format = NumberRestrictions.NumberRestrictionFormat(rawValue: formatString)
        }
        restrictions.multipleOf = yaml["multipleOf"].int
        
        return restrictions
    }
    
    private func parseFileRestrictions(_ yaml: Yaml) throws -> FileRestrictions? {
        let restrictions = FileRestrictions()
        
        restrictions.fileTypes  = try parseMediaTypes(ParseInput(yaml["fileTypes"]))
        restrictions.minLength  = yaml["minLength"].int
        restrictions.maxLength  = yaml["maxLength"].int
        
        return restrictions
    }
    
}

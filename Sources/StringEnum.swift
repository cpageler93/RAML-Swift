//
//  StringEnum.swift
//  RAML
//
//  Created by Christoph Pageler on 19.07.17.
//

import Foundation
import Yaml

public class StringEnum {
    
    public var items: [String]
    
    public init(items: [String]) {
        self.items = items
    }
    
    public func contains(_ string: String) -> Bool {
        return items.contains(string)
    }
    
    public func count() -> Int {
        return items.count
    }
    
}


// MARK: Parsing String Enum
internal extension RAML {
    
    internal func parseStringEnum(_ input: ParseInput) throws -> StringEnum? {
        guard let yaml = input.yaml else { return nil }
        
        switch yaml {
        case .array(let yamlArray):
            return try parseStringEnum(array: yamlArray)
        default:
            return nil
        }
    }
    
    private func parseStringEnum(array: [Yaml]) throws -> StringEnum {
        var enumValues: [String] = []
        for enumYaml in array {
            guard let enumYamlString = enumYaml.string else {
                throw RAMLError.ramlParsingError(.invalidDataType(for: "String Enum Value",
                                                                  mustBeKindOf: "String"))
            }
            enumValues.append(enumYamlString)
        }
        return StringEnum(items: enumValues)
    }
    
}

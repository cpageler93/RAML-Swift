//
//  BaseURI.swift
//  RAML
//
//  Created by Christoph on 30.06.17.
//

import Foundation
import Yaml

public class BaseURI: HasAnnotations {
    
    public var value: String
    public var annotations: [Annotation]?
    
    public init(value: String) {
        self.value = value
        self.annotations = []
    }
    
    internal init() {
        value = ""
    }
    
}


// MARK: BaseURI Parsing
internal extension RAML {
    
    internal func parseBaseURI(_ input: ParseInput) throws -> BaseURI? {
        guard let yaml = input.yaml else { return nil }
        
        switch yaml {
        case .string(let yamlString):
            return try parseBaseURI(string: yamlString)
        case .dictionary(let yamlDict):
            return try parseBaseURI(dict: yamlDict)
        default:
            return nil
        }
        
    }
    
    private func parseBaseURI(string: String) throws -> BaseURI {
        return BaseURI(value: string)
    }
        
    private func parseBaseURI(dict: [Yaml: Yaml]) throws -> BaseURI {
        guard let value = dict["value"]?.string else {
            throw RAMLError.ramlParsingError(.missingValueFor(key: "value"))
        }
        let baseURI = BaseURI(value: value)
        baseURI.annotations = try parseAnnotations(dict: dict)
        return baseURI
    }
}


// MARK: Default Values
public extension BaseURI {
    
    public convenience init(initWithDefaultsBasedOn baseURI: BaseURI) {
        self.init()
        
        self.value          = baseURI.value
        self.annotations    = baseURI.annotations?.map { $0.applyDefaults() }
    }

    public func applyDefaults() -> BaseURI {
        return BaseURI(initWithDefaultsBasedOn: self)
    }
    
}

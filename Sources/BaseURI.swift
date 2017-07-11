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
    
}


// MARK: BaseURI Parsing
internal extension RAML {
    
    internal func parseBaseURI(string: String) throws -> BaseURI {
        return BaseURI(value: string)
    }
        
    internal func parseBaseURI(yaml: [Yaml: Yaml]) throws -> BaseURI {
        guard let value = yaml["value"]?.string else {
            throw RAMLError.ramlParsingError(.missingValueFor(key: "value"))
        }
        let baseURI = BaseURI(value: value)
        baseURI.annotations = try parseAnnotations(yaml)
        return baseURI
    }
}

//
//  BaseURI.swift
//  RAML
//
//  Created by Christoph on 30.06.17.
//

import Foundation
import Yaml

public class BaseURI {
    
    public var value: String
    public var annotations: [Annotation]
    
    public init(value: String) {
        self.value = value
        self.annotations = []
    }
    
}


// MARK: BaseURI Parsing
extension RAML {
    
    internal func parseBaseURI(_ yaml: [Yaml: Yaml]) throws -> BaseURI {
        guard let value = yaml["value"]?.string else { throw RAMLError.ramlParsingError(message: "`value` must be set in baseUri") }
        let baseURI = BaseURI(value: value)
        baseURI.annotations = try parseAnnotations(yaml)
        return baseURI
    }
    
}

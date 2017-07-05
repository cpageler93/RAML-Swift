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
    public var annotations: [Annotation]?
    
    public init(value: String) {
        self.value = value
        self.annotations = []
    }
    
}


// MARK: BaseURI Parsing
extension RAML {
    
    internal func parseBaseURI(string: String) throws -> BaseURI {
        let value = parseBaseURIValue(string)
        return BaseURI(value: value)
    }
        
    internal func parseBaseURI(yaml: [Yaml: Yaml]) throws -> BaseURI {
        guard let rawValue = yaml["value"]?.string else { throw RAMLError.ramlParsingError(message: "`value` must be set in baseUri") }
        let value = parseBaseURIValue(rawValue)
        let baseURI = BaseURI(value: value)
        baseURI.annotations = try parseAnnotations(yaml)
        return baseURI
    }
    
    private func parseBaseURIValue(_ string: String) -> String {
        var newString = string
        while newString.hasSuffix("/") {
            newString = String(newString.dropLast())
        }
        return newString
    }
    
}

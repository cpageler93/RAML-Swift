//
//  SecuritySchemeDescription.swift
//  RAML
//
//  Created by Christoph Pageler on 08.07.17.
//

import Foundation
import Yaml

public class SecuritySchemeDescription: HasHeaders, HasMethodResponses, HasAnnotations {
    
    public var headers: [Header]?
    // queryParameters
    // queryString
    public var responses: [MethodResponse]?
    public var annotations: [Annotation]?
    
}


// MARK: Parsing Security Scheme Description
internal extension RAML {
    
    internal func parseSecuritySchemeDescription(yaml: Yaml?) throws -> SecuritySchemeDescription? {
        guard let yaml = yaml else { return nil }
        
        switch yaml {
        case .dictionary(let yamlDict):
            return try parseSecuritySchemeDescription(dict: yamlDict)
        default:
            return nil
        }
        
    }
    
    internal func parseSecuritySchemeDescription(dict: [Yaml: Yaml]) throws -> SecuritySchemeDescription {
        let securitySchemeDescription = SecuritySchemeDescription()
        
        securitySchemeDescription.headers   = try parseHeaders(yaml: dict["headers"])
        securitySchemeDescription.responses = try parseResponses(yaml: dict["responses"])
        
        return securitySchemeDescription
    }
    
}

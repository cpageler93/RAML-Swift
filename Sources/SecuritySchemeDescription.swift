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
    
    internal func parseSecuritySchemeDescription(_ yaml: [Yaml: Yaml]) throws -> SecuritySchemeDescription {
        let securitySchemeDescription = SecuritySchemeDescription()
        
        if let yamlHeaders = yaml["headers"]?.dictionary {
            securitySchemeDescription.headers = try parseHeaders(yamlHeaders)
        }
        
        if let yamlResponses = yaml["responses"]?.dictionary {
            securitySchemeDescription.responses = try parseResponses(yamlResponses)
        }
        
        return securitySchemeDescription
    }
    
}

//
//  SecuritySchemeDescription.swift
//  RAML
//
//  Created by Christoph Pageler on 08.07.17.
//

import Foundation
import Yaml
import PathKit

public class SecuritySchemeDescription: HasHeaders, HasMethodResponses, HasAnnotations {
    
    public var headers: [Header]?
    // queryParameters
    // queryString
    public var responses: [MethodResponse]?
    public var annotations: [Annotation]?
    
}


// MARK: Parsing Security Scheme Description
internal extension RAML {
    
    internal func parseSecuritySchemeDescription(_ input: ParseInput) throws -> SecuritySchemeDescription? {
        guard let yaml = input.yaml else { return nil }
        
        switch yaml {
        case .dictionary(let yamlDict):
            return try parseSecuritySchemeDescription(dict: yamlDict, parentFilePath: input.parentFilePath)
        default:
            return nil
        }
        
    }
    
    private func parseSecuritySchemeDescription(dict: [Yaml: Yaml], parentFilePath: Path?) throws -> SecuritySchemeDescription {
        let securitySchemeDescription = SecuritySchemeDescription()
        
        securitySchemeDescription.headers   = try parseHeaders(ParseInput(dict["headers"], parentFilePath))
        securitySchemeDescription.responses = try parseResponses(ParseInput(dict["responses"], parentFilePath))
        
        return securitySchemeDescription
    }
    
}


// MARK: Default Values
public extension SecuritySchemeDescription {
    
    public convenience init(initWithDefaultsBasedOn securitySchemeDescription: SecuritySchemeDescription, raml: RAML) {
        self.init()
        
        self.headers        = securitySchemeDescription.headers?.map { $0.applyDefaults() }
        // queryParameters
        // queryString
        self.responses      = securitySchemeDescription.responses?.map { $0.applyDefaults(raml: raml) }
        self.annotations    = securitySchemeDescription.annotations?.map { $0.applyDefaults() }
    }
    
    public func applyDefaults(raml: RAML) -> SecuritySchemeDescription {
        return SecuritySchemeDescription(initWithDefaultsBasedOn: self, raml: raml)
    }
    
}

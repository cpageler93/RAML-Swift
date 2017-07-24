//
//  SecuritySchemeUsage.swift
//  RAML
//
//  Created by Christoph on 12.07.17.
//

import Foundation
import Yaml

public class SecuritySchemeUsage {
    
    public var identifier: String
    public var parameters: [Yaml: Yaml]?
    
    public init(identifier: String) {
        self.identifier = identifier
    }
    
    internal init() {
        self.identifier = ""
    }
    
}

// MARK: Parsing Security Scheme Usages
internal extension RAML {
    
    internal func parseSecuritySchemeUsages(_ input: ParseInput) throws -> [SecuritySchemeUsage]? {
        guard let yaml = input.yaml else { return nil }
        
        switch yaml {
        case .array(let yamlArray):
            return try parseSecuritySchemeUsages(array: yamlArray)
        case .null:
            return nil
        default:
            return nil
        }
        
        // consider includes
    }
    
    private func parseSecuritySchemeUsages(array: [Yaml]) throws -> [SecuritySchemeUsage] {
        var securitySchemeUsages: [SecuritySchemeUsage] = []
        for yaml in array {
            let securitySchemeUsage = try parseSecuritySchemeUsage(yaml: yaml)
            securitySchemeUsages.append(securitySchemeUsage)
        }
        return securitySchemeUsages
    }
    
    private func parseSecuritySchemeUsage(yaml: Yaml) throws -> SecuritySchemeUsage {
        
        switch yaml {
        case .string(let yamlString):
            return SecuritySchemeUsage(identifier: yamlString)
        case .dictionary(let yamlDict):
            guard
                let yamlKeyString = yamlDict.keys.first?.string,
                let yamlValueDict = yamlDict.values.first?.dictionary
            else {
                throw RAMLError.ramlParsingError(.failedParsingSecuritySchemeUsage)
            }
            let securitySchemeUsage = SecuritySchemeUsage(identifier: yamlKeyString)
            securitySchemeUsage.parameters = yamlValueDict
            return securitySchemeUsage
        case .null:
            return SecuritySchemeUsage(identifier: "null")
        default:
            throw RAMLError.ramlParsingError(.failedParsingSecuritySchemeUsage)
        }
        
    }
    
}


public protocol HasSecuritySchemeUsages {
    
    var securedBy: [SecuritySchemeUsage]? { get set }
    
}

public extension HasSecuritySchemeUsages {
    
    public func securitySchemeUsageWith(identifier: String) -> SecuritySchemeUsage? {
        for securitySchemeUsage in securedBy ?? [] {
            if securitySchemeUsage.identifier == identifier {
                return securitySchemeUsage
            }
        }
        return nil
    }
    
    public func hasSecuritySchemeUsageWith(identifier: String) -> Bool {
        return securitySchemeUsageWith(identifier: identifier) != nil
    }
    
}


// MARK: Default Values
public extension SecuritySchemeUsage {
    
    public convenience init(initWithDefaultsBasedOn securitySchemeUsage: SecuritySchemeUsage) {
        self.init()
        
        self.identifier = securitySchemeUsage.identifier
        self.parameters = securitySchemeUsage.parameters
    }
    
    public func applyDefaults() -> SecuritySchemeUsage {
        return SecuritySchemeUsage(initWithDefaultsBasedOn: self)
    }
    
}


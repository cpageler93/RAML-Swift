//
//  ResourceMethodResponse.swift
//  RAML
//
//  Created by Christoph Pageler on 30.06.17.
//

import Foundation
import Yaml

public class ResourceMethodResponse: HasAnnotations, HasResourceHeaders {
    
    public var code: Int
    public var description: String?
    public var annotations: [Annotation]?
    public var headers: [ResourceHeader]?
    // public var body
    
    public init(code: Int) {
        self.code = code
    }
}

// MARK: Response Parsing
extension RAML {
    
    internal func parseResponses(_ yaml: [Yaml: Yaml]) throws -> [ResourceMethodResponse] {
        var responses: [ResourceMethodResponse] = []
        for (key, value) in yaml {
            guard let keyString = key.string, let keyInt = Int(keyString) else { throw RAMLError.invalidRAMLVersion(message: "response key must be a int `\(key)`") }
            let response = try parseResponse(code: keyInt, yaml: value)
            responses.append(response)
        }
        return responses
    }
    
    private func parseResponse(code: Int, yaml: Yaml) throws -> ResourceMethodResponse {
        let response = ResourceMethodResponse(code: code)
        
        if let descriptionString = yaml["description"].string {
            response.description = descriptionString
        }
        
        if let yamlDictionary = yaml.dictionary {
            response.annotations = try parseAnnotations(yamlDictionary)
        }
        
        if let headerYaml = yaml["headers"].dictionary {
            response.headers = try parseHeaders(headerYaml)
        }
        
        return response
    }
    
}

public protocol HasResourceMethodResponses {
    var responses: [ResourceMethodResponse]? { get set }
}

public extension HasResourceMethodResponses {
    
    public func responseWith(code: Int) -> ResourceMethodResponse? {
        for response in responses ?? [] {
            if response.code == code {
                return response
            }
        }
        return nil
    }
    
}

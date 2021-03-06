//
//  ResourceMethodResponse.swift
//  RAML
//
//  Created by Christoph Pageler on 30.06.17.
//

import Foundation
import Yaml
import PathKit

public class MethodResponse: HasAnnotations, HasHeaders {
    
    public var code: Int
    public var description: String?
    public var annotations: [Annotation]?
    public var headers: [Header]?
    public var body: Body?
    
    public init(code: Int) {
        self.code = code
    }
    
    internal init() {
        self.code = 0
    }
}


// MARK: Response Parsing
internal extension RAML {
    
    internal func parseResponses(_ input: ParseInput) throws -> [MethodResponse]? {
        guard let yaml = input.yaml else { return nil }
        
        switch yaml {
        case .dictionary(let yamlDict):
            return try parseResponses(dict: yamlDict, parentFilePath: input.parentFilePath)
        default:
            return nil
        }
        
    }
    
    internal func parseResponses(dict: [Yaml: Yaml], parentFilePath: Path?) throws -> [MethodResponse] {
        var responses: [MethodResponse] = []
        for (key, value) in dict {
            guard let keyString = key.string, let keyInt = Int(keyString) else {
                throw RAMLError.ramlParsingError(.invalidDataType(for: "Response Key",
                                                                  mustBeKindOf: "Int"))
            }
            let response = try parseResponse(code: keyInt, yaml: value, parentFilePath: parentFilePath)
            responses.append(response)
        }
        return responses
    }
    
    private func parseResponse(code: Int, yaml: Yaml, parentFilePath: Path?) throws -> MethodResponse {
        let response = MethodResponse(code: code)
        
        response.description    = yaml["description"].string
        response.annotations    = try parseAnnotations(ParseInput(yaml, parentFilePath))
        response.headers        = try parseHeaders(ParseInput(yaml["headers"], parentFilePath))
        response.body           = try parseBody(ParseInput(yaml["body"], parentFilePath))
        
        return response
    }
    
}


public protocol HasMethodResponses {
    
    var responses: [MethodResponse]? { get set }
    
}


public extension HasMethodResponses {
    
    public func responseWith(code: Int) -> MethodResponse? {
        for response in responses ?? [] {
            if response.code == code {
                return response
            }
        }
        return nil
    }
    
    public func hasResponseWith(code: Int) -> Bool {
        return responseWith(code: code) != nil
    }
    
}


// MARK: Default Values
public extension MethodResponse {
    
    internal func bodyOrDefaults(raml: RAML) -> Body {
        if let body = body { return body.applyDefaults(raml: raml) }
        
        let defaultBody = Body()
        return defaultBody.applyDefaults(raml: raml)
    }
    
    public convenience init(initWithDefaultsBasedOn methodResponse: MethodResponse, raml: RAML) {
        self.init()
        
        self.code           = methodResponse.code
        self.description    = methodResponse.description
        self.annotations    = methodResponse.annotations?.map { $0.applyDefaults() }
        self.headers        = methodResponse.headers?.map { $0.applyDefaults() }
        self.body           = methodResponse.bodyOrDefaults(raml: raml)
    }
    
    public func applyDefaults(raml: RAML) -> MethodResponse {
        return MethodResponse(initWithDefaultsBasedOn: self, raml: raml)
    }
    
}


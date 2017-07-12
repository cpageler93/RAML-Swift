//
//  ResourceMethodResponse.swift
//  RAML
//
//  Created by Christoph Pageler on 30.06.17.
//

import Foundation
import Yaml

public class MethodResponse: HasAnnotations, HasHeaders {
    
    public var code: Int
    public var description: String?
    public var annotations: [Annotation]?
    public var headers: [Header]?
    public var body: ResponseBody?
    
    public init(code: Int) {
        self.code = code
    }
}


// MARK: Response Parsing
internal extension RAML {
    
    internal func parseResponses(yaml: Yaml?) throws -> [MethodResponse]? {
        guard let yaml = yaml else { return nil }
        
        switch yaml {
        case .dictionary(let yamlDict):
            return try parseResponses(dict: yamlDict)
        default:
            return nil
        }
        
    }
    
    internal func parseResponses(dict: [Yaml: Yaml]) throws -> [MethodResponse] {
        var responses: [MethodResponse] = []
        for (key, value) in dict {
            guard let keyString = key.string, let keyInt = Int(keyString) else {
                throw RAMLError.ramlParsingError(.invalidDataType(for: "Response Key",
                                                                  mustBeKindOf: "Int"))
            }
            let response = try parseResponse(code: keyInt, yaml: value)
            responses.append(response)
        }
        return responses
    }
    
    private func parseResponse(code: Int, yaml: Yaml) throws -> MethodResponse {
        let response = MethodResponse(code: code)
        
        response.description    = yaml["description"].string
        response.annotations    = try parseAnnotations(yaml: yaml)
        response.headers        = try parseHeaders(yaml: yaml["headers"])
        response.body           = try parseResponseBody(yaml: yaml["body"])
        
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

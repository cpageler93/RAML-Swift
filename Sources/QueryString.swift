//
//  QueryString.swift
//  RAML
//
//  Created by Christoph Pageler on 19.07.17.
//

import Foundation
import Yaml

public class QueryString: HasExamples {
    
    public var type: DataType?
	public var examples: [Example]?
    
}


// MARK: Parsing Query String
internal extension RAML {
    
    internal func parseQueryString(_ input: ParseInput) throws -> QueryString? {
        guard let yaml = input.yaml else { return nil }
        
        switch yaml {
        case .dictionary(let yamlDict):
            return try parseQueryString(dict: yamlDict)
        default:
            return nil
        }
    }
    
    private func parseQueryString(dict: [Yaml: Yaml]) throws -> QueryString {
        let queryString = QueryString()
        
        if let typeYaml = dict["type"] {
            queryString.type = try DataType.dataTypeEnumFrom(yaml: typeYaml)
        }
        queryString.examples = try parseExampleOrExamples(yamlDict: dict)
        
        return queryString
    }
    
}


// MARK: Default Values
public extension QueryString {
    
    public convenience init(initWithDefaultsBasedOn queryString: QueryString) {
        self.init()
        
        self.type       = queryString.type
        self.examples   = queryString.examples?.map { $0.applyDefaults() }
    }
    
    public func applyDefaults() -> QueryString {
        return QueryString(initWithDefaultsBasedOn: self)
    }
    
}

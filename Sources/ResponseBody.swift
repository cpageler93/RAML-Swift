//
//  ResponseBody.swift
//  RAML
//
//  Created by Christoph on 06.07.17.
//

import Foundation
import Yaml

public class ResponseBody: HasBodyMediaTypes {
    
    public var type: DataType?
    public var properties: [Property]?
    public var mediaTypes: [BodyMediaType]?
    
//    public var example
    
}


// MARK: Response Body Parsing
internal extension RAML {
    
    internal func parseResponseBody(_ input: ParseInput) throws -> ResponseBody? {
        guard let yaml = input.yaml else { return nil }
        
        switch yaml {
        case .string(let yamlString):
            let body = ResponseBody()
            body.type = DataType.dataTypeEnumFrom(string: yamlString)
            return body
        case .dictionary:
            let body = ResponseBody()
            body.mediaTypes = try parseBodyMediaTypes(input)
            return body
        default:
            return nil
        }
        
    }
}

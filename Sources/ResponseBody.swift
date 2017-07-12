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
    
    internal func parseResponseBody(yaml: Yaml?) throws -> ResponseBody? {
        guard let yaml = yaml else { return nil }
        
        switch yaml {
        case .string(let yamlString):
            let body = ResponseBody()
            body.type = DataType.dataTypeEnumFrom(string: yamlString)
            return body
        case .dictionary:
            let body = ResponseBody()
            body.mediaTypes = try parseBodyMediaTypes(yaml: yaml)
            return body
        default:
            return nil
        }
        
    }
}

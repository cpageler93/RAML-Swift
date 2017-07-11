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
    
    internal func parseResponseBody(_ yaml: Yaml) throws -> ResponseBody? {
        if let bodyString = yaml.string {
            let body = ResponseBody()
            body.type = DataType.dataTypeEnumFrom(string: bodyString)
            return body
        } else if let bodyYamlDict = yaml.dictionary {
            let body = ResponseBody()
            
            if let mediaTypes = try parseBodyMediaTypes(bodyYamlDict) {
                body.mediaTypes = mediaTypes
            }
            
            return body
        }
        return nil
    }
}

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
            body.mediaTypes = inheritedBodyMediaTypes()
            return body
        } else if let bodyYamlDict = yaml.dictionary {
            let body = ResponseBody()
            if let mediaTypes = try parseBodyMediaTypes(bodyYamlDict) {
                body.mediaTypes = mediaTypes
            } else {
                body.mediaTypes = inheritedBodyMediaTypes()
            }
            return body
        }
        return nil
    }
    
    private func inheritedBodyMediaTypes() -> [BodyMediaType]? {
        var bodyMediaTypes: [BodyMediaType] = []
        
        for mediaType in mediaTypes ?? [] {
            let bodyMediaType = BodyMediaType(identifier: mediaType.identifier)
            bodyMediaTypes.append(bodyMediaType)
        }

        if bodyMediaTypes.count > 0 {
            return bodyMediaTypes
        } else {
            return nil
        }
    }
    
}

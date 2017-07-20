//
//  Body.swift
//  RAML
//
//  Created by Christoph on 06.07.17.
//

import Foundation
import Yaml

public class Body: HasBodyMediaTypes, HasAnnotations {
    
    public var type: DataType?
    public var properties: [Property]?
    public var examples: [Example]?
    public var mediaTypes: [BodyMediaType]?
    public var annotations: [Annotation]?
    
}


// MARK: Body Parsing
internal extension RAML {
    
    internal func parseBody(_ input: ParseInput) throws -> Body? {
        guard let yaml = input.yaml else { return nil }
        
        switch yaml {
        case .string(let yamlString):
            let body = Body()
            body.type = DataType.dataTypeEnumFrom(string: yamlString)
            return body
        case .dictionary:
            let body = Body()
            body.type           = try DataType.dataTypeEnumFrom(yaml: yaml, dictKey: "type")
            body.properties     = try parseProperties(yaml: yaml)
            body.examples       = try parseExampleOrExamples(yamlDict: yaml.dictionary)
            body.mediaTypes     = try parseBodyMediaTypes(input)
            body.annotations    = try parseAnnotations(input)
            return body
        default:
            return nil
        }
        
    }
}

//
//  RAML+Protocols.swift
//  RAML
//
//  Created by Christoph Pageler on 24.06.17.
//

import Foundation
import Yaml

public struct Protocols: OptionSet {
    public init(rawValue: Protocols.RawValue) {
        self.rawValue = rawValue
    }
    public let rawValue: Int
    
    static let http  = Protocols(rawValue: 1 << 0)
    static let https = Protocols(rawValue: 1 << 1)
}


// MARK: Protocols Parsing
extension RAML {
    
    internal func parseProtocols(_ yaml: [Yaml]) throws -> Protocols {
        var protocols: Protocols = []
        for protocolYaml in yaml {
            guard let protocolString = protocolYaml.string else {
                throw RAMLError.ramlParsingError(.invalidDataType(for: "Protocol",
                                                                  mustBeKindOf: "String"))
            }
            
            switch protocolString.uppercased() {
            case "HTTP": protocols.insert(.http)
            case "HTTPS": protocols.insert(.https)
            default:
                throw RAMLError.ramlParsingError(.invalidProtocol(protocolString))
            }
        }
        return protocols
    }
    
}

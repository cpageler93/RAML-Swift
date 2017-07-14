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
internal extension RAML {
    
    internal func parseProtocols(_ input: ParseInput) throws -> Protocols? {
        guard let yaml = input.yaml else { return nil }
        
        switch yaml {
        case .array(let yamlArray):
            return try parseProtocols(array: yamlArray)
        default:
            return nil
        }
    }
    
    private func parseProtocols(array: [Yaml]) throws -> Protocols {
        var protocols: Protocols = []
        for protocolYaml in array {
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


public protocol HasProtocols {
    
    var protocols: Protocols? { get set }
    
}

public extension HasProtocols {
    
    public func hasProtocol(_ p: Protocols) -> Bool {
        return protocols?.contains(p) ?? false
    }
    
}

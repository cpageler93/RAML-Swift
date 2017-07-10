//
//  RAMLPreprocessor.swift
//  RAML
//
//  Created by Christoph on 10.07.17.
//

import Foundation

public class RAMLPreprocessor {
    
    public var raml: RAML
    
    public init(raml: RAML) {
        self.raml = raml
    }
    
    public func enumerateResourceMethods(recursive: Bool = true, closure: @escaping (Resource) -> (Void)) {
        func enumerate(resources: [Resource]?) {
            for resource in resources ?? [] {
                closure(resource)
                if recursive {
                    enumerate(resources: resource.resources)
                }
            }
        }
        enumerate(resources: raml.resources)
    }
    
}

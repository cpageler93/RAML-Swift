//
//  RAMLPreprocessor+Routes.swift
//  RAML
//
//  Created by Christoph on 10.07.17.
//

import Foundation

public extension RAMLPreprocessor {
    
    public func routes() -> String {
        var routes: [String] = []
        enumerateResourceMethods { resource in
            routes.append("GET \(resource.absolutePath())")
        }
        return routes.joined(separator: "\n")
    }
    
}


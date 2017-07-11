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
        enumerateResources { resource in
            routes.append("GET \(resource.path)")
        }
        return routes.joined(separator: "\n")
    }
    
}


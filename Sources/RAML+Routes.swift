//
//  RAML+Routes.swift
//  RAML
//
//  Created by Christoph Pageler on 08.07.17.
//

import Foundation

public extension RAML {
    
    public func routes() -> String {
        return routesFor(resources: resources).joined(separator: "\n")
    }
    
    private func routesFor(resources: [Resource]?) -> [String] {
        var routes: [String] = []
        for resource in resources ?? [] {
            routes += routesFor(resource: resource)
        }
        return routes
    }
    
    private func routesFor(resource: Resource) -> [String] {
        var routes: [String] = []
        
        // own
        if let methods = resource.methods {
            fatalError("NOT TESTED")
        } else {
            let route = "GET \(resource.absolutePath())"
            routes.append(route)
        }
        
        // childred
        routes += routesFor(resources: resource.resources)
        
        return routes
    }
    
}

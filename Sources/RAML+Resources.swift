//
//  RAML+Resources.swift
//  RAML
//
//  Created by Christoph Pageler on 24.07.17.
//

import Foundation

public extension RAML {
    
    public func enumerateResource(_ closure: @escaping (_ resource: Resource,_ resourceChain: [Resource], _ stop: inout Bool) -> ()) {
        enumerateResourcesIn(typeWhoHasResources: self) { resource, resourceChain, stop in
            closure(resource, resourceChain, &stop)
        }
    }
    
    public func absolutePathForResource(_ resourceToFind: Resource) -> String {
        var foundResourceWithChain: [Resource]? = nil
        enumerateResource { resource, resourceChain, stop in
            if resource === resourceToFind {
                stop = true
                foundResourceWithChain = resourceChain
            }
        }
        
        if let foundResourceWithChain = foundResourceWithChain {
            var path = ""
            for resource in foundResourceWithChain {
                path += resource.path
            }
            return path
        } else {
            return resourceToFind.path
        }
    }
    
    private func enumerateResourcesIn(typeWhoHasResources: HasResources,
                                      resourceChain: [Resource]? = nil,
                                      closure: @escaping (_ resource: Resource, _ resourceChain: [Resource], _ stop: inout Bool) -> ()) {
        // enumerate resource
        for resource in typeWhoHasResources.resources ?? [] {
            // make chain variable
            var resourceChainForDepth = resourceChain ?? []
            
            // append chain
            resourceChainForDepth.append(resource)
            
            // call closure and check for stop
            var stop = false
            closure(resource, resourceChainForDepth, &stop)
            if stop { return }
            
            // call recursive
            enumerateResourcesIn(typeWhoHasResources: resource,
                                 resourceChain: resourceChainForDepth,
                                 closure: closure)
        }
    }
}

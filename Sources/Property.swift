//
//  Property.swift
//  RAML
//
//  Created by Christoph Pageler on 24.06.17.
//

import Foundation

public class Property {
    
    public var name: String
    public var required: Bool = true
    public var type: DataType?
    
    init(name: String) {
        self.name = name
    }
    
}

//
//  Type.swift
//  RAML
//
//  Created by Christoph Pageler on 24.06.17.
//

import Foundation

public class Type {
    
    public var name: String
    // default?
    public var type: DataType?
    public var example: TypeExample?
    public var examples: [TypeExample]?
    public var displayName: String?
    public var description: String?
    // annotations?
    // facets?
    // xml?
    // enum?
    
    // MARK: Object Type
    
    var properties: [Property]?
    var minProperties: Int?
    var maxProperties: Int?
    var additionalProperties: Bool = true
    var discriminator: String?
    var discriminatorValue: String?
    
    init(name: String) {
        self.name = name
        
    }
    
}

//
//  TypeExample.swift
//  RAML
//
//  Created by Christoph Pageler on 24.06.17.
//

import Foundation
import Yaml

public class TypeExample {
    
    public var displayName: String?
    public var description: String?
    public var annotations: [Annotation]
    public var value: [Yaml: Yaml]
    
    init(value: [Yaml: Yaml]) {
        self.value = value
        self.annotations = []
    }
    
}

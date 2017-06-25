//
//  TypeExample.swift
//  RAML
//
//  Created by Christoph Pageler on 24.06.17.
//

import Foundation
import Yaml

public class TypeExample {
    
    var displayName: String?
    var description: String?
//     annotations
    var value: [Yaml: Yaml]
    
    init(value: [Yaml: Yaml]) {
        self.value = value
    }
    
}

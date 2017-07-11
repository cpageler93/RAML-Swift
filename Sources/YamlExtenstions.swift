//
//  YamlExtenstions.swift
//  RAML
//
//  Created by Christoph Pageler on 10.07.17.
//

import Foundation
import Yaml

internal extension Yaml {
    
    internal init(array elements: [Yaml]) {
        self = .array(elements)
    }
    
    internal init(dictionary elements: [Yaml: Yaml]) {
        var dictionary = [Yaml: Yaml]()
        for (k, v) in elements {
            dictionary[k] = v
        }
        self = .dictionary(dictionary)
    }
    
    internal static func hasKeyWith(string: String, inDictionary dictionary: [Yaml: Yaml]) -> Bool {
        for (key, _) in dictionary {
            guard let keyString = key.string else { continue }
            if keyString == string { return true }
        }
        return false
    }
}

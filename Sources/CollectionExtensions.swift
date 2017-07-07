//
//  CollectionExtensions.swift
//  RAML
//
//  Created by Christoph on 14.06.17.
//

import Foundation

internal extension Collection {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

}

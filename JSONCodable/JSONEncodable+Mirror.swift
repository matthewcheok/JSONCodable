//
//  JSONEncodable+Mirror.swift
//  JSONCodable
//
//  Created by Andy Steinmann on 7/14/16.
//
//

public extension Mirror {
    /**
     Builds an array of all properties from current class and all super classes
     
     - returns: array of Tuples containing the label and value for each property
     */
    public func getAllProperties() -> [(label: String?, value: Any)] {
        var children = Array(self.children)
        children.append(contentsOf: self.superclassMirror?.getAllProperties() ?? [])
        
        return children
    }
}

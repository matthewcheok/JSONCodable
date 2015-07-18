//
//  JSONHelpers.swift
//  project20
//
//  Created by Matthew Cheok on 17/7/15.
//  Copyright © 2015 matthewcheok. All rights reserved.
//

// Array handling

protocol JSONArray {
    var count: Int { get } 
    func elementsAreJSONEncodable() -> Bool
    func elementsMadeJSONEncodable() -> [JSONEncodable]
}

extension Array: JSONArray {
    func elementsAreJSONEncodable() -> Bool {
        return Element.self is JSONEncodable.Type
    }
    
    func elementsMadeJSONEncodable() -> [JSONEncodable] {
        return self.map {$0 as! JSONEncodable}
    }
}


// Optional handling

protocol JSONOptional {
    var wrapped: Any? { get }
}

extension Optional: JSONOptional {
    var wrapped: Any? { return self }
}

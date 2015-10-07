//
//  JSONHelpers.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 17/7/15.
//  Copyright © 2015 matthewcheok. All rights reserved.
//

// Dictionary handling

protocol JSONDictionary {
    func dictionaryIsJSONEncodable() -> Bool
    func dictionaryMadeJSONEncodable() -> [String: JSONEncodable]
}

extension Dictionary : JSONDictionary {
    func dictionaryIsJSONEncodable() -> Bool {
        return Key.self is String.Type && Value.self is JSONEncodable.Type
    }
    
    func dictionaryMadeJSONEncodable() -> [String: JSONEncodable] {
        var dict: [String: JSONEncodable] = [:]
        for (k, v) in self {
            dict[String(k)] = v as? JSONEncodable
        }
        return dict
    }
}

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

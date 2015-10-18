//
//  JSONHelpers.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 17/7/15.
//  Copyright © 2015 matthewcheok. All rights reserved.
//

// Convenience

public typealias JSONObject = [String: AnyObject]

// Dictionary handling

protocol JSONDictionary {
    var count: Int { get } 
    func valuesAreJSONEncodable() -> Bool
    func valuesMadeJSONEncodable() -> [String: JSONEncodable]
}

extension Dictionary : JSONDictionary {
    func valuesAreJSONEncodable() -> Bool {
		return Key.self is String.Type && (Value.self is JSONEncodable.Type || Value.self is JSONEncodable.Protocol)
    }
    
    func valuesMadeJSONEncodable() -> [String: JSONEncodable] {
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
		return Element.self is JSONEncodable.Type || Element.self is JSONEncodable.Protocol
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

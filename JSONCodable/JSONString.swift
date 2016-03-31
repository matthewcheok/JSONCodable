//
//  JSONString.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 17/7/15.
//  Copyright © 2015 matthewcheok. All rights reserved.
//

import Foundation

public extension JSONEncodable {
    public func toJSONString() throws -> String {
        switch self {
        case let str as String:
            return escapeJSONString(str)
        case is Bool, is Int, is Float, is Double:
            return String(self)
        default:
            let json = try toJSON()
            #if !swift(>=3.0)
            let data = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions(rawValue: 0))
            #else
                let data = try NSJSONSerialization.data(withJSONObject: json, options: NSJSONWritingOptions(rawValue: 0))
            #endif
            guard let string = NSString(data: data, encoding: NSUTF8StringEncoding) else {
                return ""
            }
            return string as String
        }
    }
}

private func escapeJSONString(str: String) -> String {
    var chars = String.CharacterView("\"")
    for c in str.characters {
        switch c {
        case "\\":
            chars.append("\\")
            chars.append("\\")
        case "\"":
            chars.append("\\")
            chars.append("\"")
        default:
            chars.append(c)
        }
    }
    chars.append("\"")
    return String(chars)
}

public extension Optional where Wrapped: JSONEncodable {
    public func toJSONString() throws -> String {
        #if !swift(>=3.0)
        switch self {
        case let .Some(jsonEncodable):
            return try jsonEncodable.toJSONString()
        case nil:
            return "null"
        }
        #else
        switch self {
        case let .some(jsonEncodable):
            return try jsonEncodable.toJSONString()
        case nil:
            return "null"
        }
        #endif
    }
}

public extension JSONDecodable {
    init(JSONString: String) throws {
        #if !swift(>=3.0)
        guard let data = JSONString.dataUsingEncoding(NSUTF8StringEncoding) else {
            throw JSONDecodableError.IncompatibleTypeError(key: "n/a", elementType: JSONString.dynamicType, expectedType: String.self)
        }
        
        let result: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
        #else
            guard let data = JSONString.data(usingEncoding:NSUTF8StringEncoding) else {
            throw JSONDecodableError.IncompatibleTypeError(key: "n/a", elementType: JSONString.dynamicType, expectedType: String.self)
        }
        
            let result: AnyObject = try NSJSONSerialization.jsonObject(with: data, options: NSJSONReadingOptions(rawValue: 0))
        #endif

        guard let converted = result as? [String: AnyObject] else {
            throw JSONDecodableError.DictionaryTypeExpectedError(key: "n/a", elementType: result.dynamicType)
        }
        
        try self.init(object: converted)
    }
}

public extension Array where Element: JSONDecodable {
    init(JSONString: String) throws {
        #if !swift(>=3.0)
        guard let data = JSONString.dataUsingEncoding(NSUTF8StringEncoding) else {
            throw JSONDecodableError.IncompatibleTypeError(key: "n/a", elementType: JSONString.dynamicType, expectedType: String.self)
        }
        
        let result: AnyObject  = try NSJSONSerialization.jsonObject(with: data, options: NSJSONReadingOptions(rawValue: 0))
        #else
            guard let data = JSONString.data(usingEncoding: NSUTF8StringEncoding) else {
            throw JSONDecodableError.IncompatibleTypeError(key: "n/a", elementType: JSONString.dynamicType, expectedType: String.self)
        }
        
            let result: AnyObject  = try NSJSONSerialization.jsonObject(with: data, options: NSJSONReadingOptions(rawValue: 0))
        #endif
        guard let converted = result as? [AnyObject] else {
            throw JSONDecodableError.ArrayTypeExpectedError(key: "n/a", elementType: result.dynamicType)
        }
        
        try self.init(JSONArray: converted)
    }
}

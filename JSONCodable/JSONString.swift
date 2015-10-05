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
            let data = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions(rawValue: 0))
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
        switch self {
        case let .Some(jsonEncodable):
            return try jsonEncodable.toJSONString()
        case nil:
            return "null"
        }
    }
}

public extension JSONDecodable {
    init?(JSONString: String) {
        guard let data = JSONString.dataUsingEncoding(NSUTF8StringEncoding) else {
            return nil
        }
        
        let result: AnyObject
        do {
            result = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
        }
        catch {
            return nil
        }
        
        guard let converted = result as? [String: AnyObject] else {
            return nil
        }
        
        self.init(JSONDictionary: converted)
    }
}

public extension Array where Element: JSONDecodable {
    init?(JSONString: String) {
        guard let data = JSONString.dataUsingEncoding(NSUTF8StringEncoding) else {
            return nil
        }
        
        let result: AnyObject
        do {
            result = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
        }
        catch {
            return nil
        }
        
        guard let converted = result as? [AnyObject] else {
            return nil
        }
        
        self.init(JSONArray: converted)
    }
}

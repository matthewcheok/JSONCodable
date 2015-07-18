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
        let json = try toJSON()
        let data = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions(rawValue: 0))
        guard let string = NSString(data: data, encoding: NSUTF8StringEncoding) else {
            return ""
        }
        return string as String
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

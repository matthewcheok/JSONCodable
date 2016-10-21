//
//  JSONDecodable.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 17/7/15.
//  Copyright © 2015 matthewcheok. All rights reserved.
//

// Decoding Errors

public enum JSONDecodableError: Error, CustomStringConvertible {
    case missingTypeError(
        key: String
    )
    case incompatibleTypeError(
        key: String,
        elementType: Any.Type,
        expectedType: Any.Type
    )
    case arrayTypeExpectedError(
        key: String,
        elementType: Any.Type
    )
    case dictionaryTypeExpectedError(
        key: String,
        elementType: Any.Type
    )
    case transformerFailedError(
        key: String
    )
    
    public var description: String {
        switch self {
        case let .missingTypeError(key: key):
            return "JSONDecodableError: Missing value for key \(key)"
        case let .incompatibleTypeError(key: key, elementType: elementType, expectedType: expectedType):
            return "JSONDecodableError: Incompatible type for key \(key); Got \(elementType) instead of \(expectedType)"
        case let .arrayTypeExpectedError(key: key, elementType: elementType):
            return "JSONDecodableError: Got \(elementType) instead of an array for key \(key)"
        case let .dictionaryTypeExpectedError(key: key, elementType: elementType):
            return "JSONDecodableError: Got \(elementType) instead of a dictionary for key \(key)"
        case let .transformerFailedError(key: key):
            return "JSONDecodableError: Transformer failed for key \(key)"
        }
    }
}

// Dictionary -> Struct

public protocol JSONDecodable {
    init(object: JSONObject) throws
    init(object: [JSONObject]) throws
}

public extension JSONDecodable {
    /// initialize with top-level Array JSON data 
    public init(object: [JSONObject]) throws {
        // use empty string key
        try self.init(object:["": object])
    }

    public init?(optional: JSONObject) {
        do {
            try self.init(object: optional)
        } catch {
            return nil
        }
    }
}

public extension Array where Element: JSONDecodable {
    init(JSONArray: [Any]) throws {
        self.init(try JSONArray.flatMap {
            guard let json = $0 as? [String : Any] else {
                throw JSONDecodableError.dictionaryTypeExpectedError(key: "n/a", elementType: type(of: $0))
            }
            return try Element(object: json)
            })
    }
}

// JSONDecoder - provides utility methods for decoding

public class JSONDecoder {
    let object: JSONObject
    
    public init(object: JSONObject) {
        self.object = object
    }
    
    /// Get index from `"[0]"` formatted `String`
    /// returns `nil` if invalid format (i.e. no brackets or contents not an `Int`)
    internal func parseArrayIndex(_ key:String) -> Int? {
        var chars = key.characters
        let first = chars.popFirst()
        let last = chars.popLast()
        if first == "[" && last == "]" {
            return Int(String(chars))
        } else {
            return nil
        }
    }
    
    private func get(_ key: String) -> Any? {
        let keys = key.replacingOccurrences(of: "[", with: ".[").components(separatedBy: ".")
        let result = keys.reduce(object as Any?) {
            value, key in
            
            switch value {
            case let dict as [String: Any]:
                return dict[key]
                
            case let arr as [Any]:
                guard let index = parseArrayIndex(key) else {
                    return nil
                }
                guard (0..<arr.count) ~= index else {
                    return nil
                }
                return arr[index]
                
            default:
                return nil
            }
        }
        return (result ?? object[key]).flatMap{$0 is NSNull ? nil : $0}
    }
    
    // JSONCompatible
    public func decode<Compatible: JSONCompatible>(_ key: String) throws -> Compatible {
        guard let value = get(key) else {
            throw JSONDecodableError.missingTypeError(key: key)
        }
        guard let compatible = value as? Compatible else {
            throw JSONDecodableError.incompatibleTypeError(key: key, elementType: type(of: value), expectedType: Compatible.self)
        }
        return compatible
    }
    
    // JSONCompatible?
    public func decode<Compatible: JSONCompatible>(_ key: String) throws -> Compatible? {
        return (get(key) ?? object[key] as Any) as? Compatible
    }
    
    // JSONDecodable
    public func decode<Decodable: JSONDecodable>(_ key: String) throws -> Decodable {
        guard let value = get(key) else {
            throw JSONDecodableError.missingTypeError(key: key)
        }
        guard let object = value as? JSONObject else {
            throw JSONDecodableError.dictionaryTypeExpectedError(key: key, elementType: type(of: value))
        }
        return try Decodable(object: object)
    }
    
    // JSONDecodable?
    public func decode<Decodable: JSONDecodable>(_ key: String) throws -> Decodable? {
        guard let value = get(key) else {
            return nil
        }
        guard let object = value as? JSONObject else {
            throw JSONDecodableError.dictionaryTypeExpectedError(key: key, elementType: type(of: value))
        }
        return try Decodable(object: object)
    }
    
    // Enum
    public func decode<Enum: RawRepresentable>(_ key: String) throws -> Enum {
        guard let value = get(key) else {
            throw JSONDecodableError.missingTypeError(key: key)
        }
        guard let raw = value as? Enum.RawValue else {
            throw JSONDecodableError.incompatibleTypeError(key: key, elementType: type(of: value), expectedType: Enum.RawValue.self)
        }
        guard let result = Enum(rawValue: raw) else {
            throw JSONDecodableError.incompatibleTypeError(key: key, elementType: Enum.RawValue.self, expectedType: Enum.self)
        }
        return result
    }
    
    // Enum?
    public func decode<Enum: RawRepresentable>(_ key: String) throws -> Enum? {
        guard let value = get(key) else {
            return nil
        }
        guard let raw = value as? Enum.RawValue else {
            throw JSONDecodableError.incompatibleTypeError(key: key, elementType: type(of: value), expectedType: Enum.RawValue.self)
        }
        guard let result = Enum(rawValue: raw) else {
            throw JSONDecodableError.incompatibleTypeError(key: key, elementType: Enum.RawValue.self, expectedType: Enum.self)
        }
        return result
    }
    
    // [JSONCompatible]
    public func decode<Element: JSONCompatible>(_ key: String) throws -> [Element] {
        guard let value = get(key) else {
            return []
        }
        guard let array = value as? [Element] else {
            throw JSONDecodableError.incompatibleTypeError(key: key, elementType: type(of: value), expectedType: [Element].self)
        }
        return array
    }
    
    // [JSONCompatible]?
    public func decode<Element: JSONCompatible>(_ key: String) throws -> [Element]? {
        guard let value = get(key) else {
            return nil
        }
        guard let array = value as? [Element] else {
            throw JSONDecodableError.incompatibleTypeError(key: key, elementType: type(of: value), expectedType: [Element].self)
        }
        return array
    }
    
    // [JSONDecodable]
    public func decode<Element: JSONDecodable>(_ key: String) throws -> [Element] {
        guard let value = get(key) else {
            return []
        }
        guard let array = value as? [JSONObject] else {
            throw JSONDecodableError.arrayTypeExpectedError(key: key, elementType: type(of: value))
        }
        return try array.flatMap { try Element(object: $0)}
    }
    
    // [JSONDecodable]?
    public func decode<Element: JSONDecodable>(_ key: String) throws -> [Element]? {
        guard let value = get(key) else {
            return nil
        }
        guard let array = value as? [JSONObject] else {
            throw JSONDecodableError.arrayTypeExpectedError(key: key, elementType: type(of: value))
        }
        return try array.flatMap { try Element(object: $0)}
    }
    
    // [[JSONDecodable]]
    public func decode<Element: JSONDecodable>(_ key: String) throws -> [[Element]] {
        guard let value = get(key) else {
            return []
        }
        guard let array = value as? [[JSONObject]] else {
            throw JSONDecodableError.arrayTypeExpectedError(key: key, elementType: type(of: value))
        }
        var res:[[Element]] = []
        
        for x in array {
            let nested = try x.flatMap { try Element(object: $0)}
            res.append(nested)
        }
        return res
    }
    
    // [[JSONCompatible]]
    public func decode<Element: JSONCompatible>(_ key: String) throws -> [[Element]] {
        guard let value = get(key) else {
            return []
        }
        guard let array = value as? [[Element]] else {
            throw JSONDecodableError.incompatibleTypeError(key: key, elementType: type(of: value), expectedType: [Element].self)
        }
        var res:[[Element]] = []
        
        for x in array {
            res.append(x)
        }
        return res
    }
    
    // [Enum]
    public func decode<Enum: RawRepresentable>(_ key: String) throws -> [Enum] {
        guard let value = get(key) else {
            return []
        }
        guard let array = value as? [Enum.RawValue] else {
            throw JSONDecodableError.arrayTypeExpectedError(key: key, elementType: type(of: value))
        }
        return array.flatMap { Enum(rawValue: $0) }
    }
    
    // [Enum]?
    public func decode<Enum: RawRepresentable>(_ key: String) throws -> [Enum]? {
        guard let value = get(key) else {
            return nil
        }
        guard let array = value as? [Enum.RawValue] else {
            throw JSONDecodableError.arrayTypeExpectedError(key: key, elementType: type(of: value))
        }
        return array.flatMap { Enum(rawValue: $0) }
    }
    
    // [String:JSONCompatible]
    public func decode<Value: JSONCompatible>(_ key: String) throws -> [String: Value] {
        guard let value = get(key) else {
            throw JSONDecodableError.missingTypeError(key: key)
        }
        guard let dictionary = value as? [String: Value] else {
            throw JSONDecodableError.incompatibleTypeError(key: key, elementType: type(of: value), expectedType: [String: Value].self)
        }
        return dictionary
    }
    
    // [String:JSONCompatible]?
    public func decode<Value: JSONCompatible>(_ key: String) throws -> [String: Value]? {
        guard let value = get(key) else {
            return nil
        }
        guard let dictionary = value as? [String: Value] else {
            throw JSONDecodableError.incompatibleTypeError(key: key, elementType: type(of: value), expectedType: [String: Value].self)
        }
        return dictionary
    }
    
    // [String:JSONDecodable]
    public func decode<Element: JSONDecodable>(_ key: String) throws -> [String: Element] {
        guard let value = get(key) else {
            throw JSONDecodableError.missingTypeError(key: key)
        }
        guard let dictionary = value as? [String: JSONObject] else {
            throw JSONDecodableError.incompatibleTypeError(key: key, elementType: type(of: value), expectedType: [String: Element].self)
        }
        var decoded = [String: Element]()
        try dictionary.forEach {
            decoded[$0] = try Element(object: $1)
        }
        return decoded
    }
    
    // [String:JSONDecodable]?
    public func decode<Element: JSONDecodable>(_ key: String) throws -> [String: Element]? {
        guard let value = get(key) else {
            return nil
        }
        guard let dictionary = value as? [String: JSONObject] else {
            throw JSONDecodableError.incompatibleTypeError(key: key, elementType: type(of: value), expectedType: [String: Element].self)
        }
        var decoded = [String: Element]()
        try dictionary.forEach {
            decoded[$0] = try Element(object: $1)
        }
        return decoded
    }
    
    // JSONTransformable
    public func decode<EncodedType, DecodedType>(_ key: String, transformer: JSONTransformer<EncodedType, DecodedType>) throws -> DecodedType {
        guard let value = get(key) else {
            throw JSONDecodableError.missingTypeError(key: key)
        }
        guard let actual = value as? EncodedType else {
            throw JSONDecodableError.incompatibleTypeError(key: key, elementType: type(of: value), expectedType: EncodedType.self)
        }
        guard let result = transformer.decoding(actual) else {
            throw JSONDecodableError.transformerFailedError(key: key)
        }
        return result
    }
    
    // JSONTransformable?
    public func decode<EncodedType, DecodedType>(_ key: String, transformer: JSONTransformer<EncodedType, DecodedType>) throws -> DecodedType? {
        guard let value = get(key) else {
            return nil
        }
        guard let actual = value as? EncodedType else {
            throw JSONDecodableError.incompatibleTypeError(key: key, elementType: type(of: value), expectedType: EncodedType.self)
        }
        guard let result = transformer.decoding(actual) else {
            throw JSONDecodableError.transformerFailedError(key: key)
        }
        return result
    }
}

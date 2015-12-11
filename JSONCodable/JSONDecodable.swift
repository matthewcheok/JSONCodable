//
//  JSONDecodable.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 17/7/15.
//  Copyright © 2015 matthewcheok. All rights reserved.
//

// Decoding Errors

public enum JSONDecodableError: ErrorType, CustomStringConvertible {
    case MissingTypeError(
        key: String
    )
    case IncompatibleTypeError(
        key: String,
        elementType: Any.Type,
        expectedType: Any.Type
    )
    case ArrayTypeExpectedError(
        key: String,
        elementType: Any.Type
    )
    case DictionaryTypeExpectedError(
        key: String,
        elementType: Any.Type
    )
    case TransformerFailedError(
        key: String
    )
    
    public var description: String {
        switch self {
        case let .MissingTypeError(key: key):
            return "JSONDecodableError: Missing value for key \(key)"
        case let .IncompatibleTypeError(key: key, elementType: elementType, expectedType: expectedType):
            return "JSONDecodableError: Incompatible type for key \(key); Got \(elementType) instead of \(expectedType)"
        case let .ArrayTypeExpectedError(key: key, elementType: elementType):
            return "JSONDecodableError: Got \(elementType) instead of an array for key \(key)"
        case let .DictionaryTypeExpectedError(key: key, elementType: elementType):
            return "JSONDecodableError: Got \(elementType) instead of a dictionary for key \(key)"
        case let .TransformerFailedError(key: key):
            return "JSONDecodableError: Transformer failed for key \(key)"
        }
    }
}

// Dictionary -> Struct

public protocol JSONDecodable {
    init(object: JSONObject) throws
}

public extension JSONDecodable {
    public init?(optional: JSONObject) {
        do {
            try self.init(object: optional)
        } catch {
            return nil
        }
    }
}

public extension Array where Element: JSONDecodable {
    init(JSONArray: [AnyObject]) throws {
        self.init(try JSONArray.flatMap {
            guard let json = $0 as? [String : AnyObject] else {
                throw JSONDecodableError.DictionaryTypeExpectedError(key: "n/a", elementType: $0.dynamicType)
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
    
    private func get(key: String) -> AnyObject? {
        let keys = key.componentsSeparatedByString(".")
        
        let result = keys.reduce(object as AnyObject?) {
            value, key in
            
            guard let dict = value as? [String: AnyObject] else {
                return nil
            }
            
            return dict[key]
        }
        return (result ?? object[key]).flatMap{$0 is NSNull ? nil : $0}
    }
    
    // JSONCompatible
    public func decode<Compatible: JSONCompatible>(key: String) throws -> Compatible {
        guard let value = get(key) else {
            throw JSONDecodableError.MissingTypeError(key: key)
        }
        guard let compatible = value as? Compatible else {
            throw JSONDecodableError.IncompatibleTypeError(key: key, elementType: value.dynamicType, expectedType: Compatible.self)
        }
        return compatible
    }
    
    // JSONCompatible?
    public func decode<Compatible: JSONCompatible>(key: String) throws -> Compatible? {
        return (get(key) ?? object[key]) as? Compatible
    }
    
    // JSONDecodable
    public func decode<Decodable: JSONDecodable>(key: String) throws -> Decodable {
        guard let value = get(key) else {
            throw JSONDecodableError.MissingTypeError(key: key)
        }
        guard let object = value as? JSONObject else {
            throw JSONDecodableError.DictionaryTypeExpectedError(key: key, elementType: value.dynamicType)
        }
        return try Decodable(object: object)
    }
    
    // JSONDecodable?
    public func decode<Decodable: JSONDecodable>(key: String) throws -> Decodable? {
        guard let value = get(key) else {
            return nil
        }
        guard let object = value as? JSONObject else {
            throw JSONDecodableError.DictionaryTypeExpectedError(key: key, elementType: value.dynamicType)
        }
        return try Decodable(object: object)
    }
    
    // Enum
    public func decode<Enum: RawRepresentable>(key: String) throws -> Enum {
        guard let value = get(key) else {
            throw JSONDecodableError.MissingTypeError(key: key)
        }
        guard let raw = value as? Enum.RawValue else {
            throw JSONDecodableError.IncompatibleTypeError(key: key, elementType: value.dynamicType, expectedType: Enum.RawValue.self)
        }
        guard let result = Enum(rawValue: raw) else {
            throw JSONDecodableError.IncompatibleTypeError(key: key, elementType: Enum.RawValue.self, expectedType: Enum.self)
        }
        return result
    }
    
    // Enum?
    public func decode<Enum: RawRepresentable>(key: String) throws -> Enum? {
        guard let value = get(key) else {
            return nil
        }
        guard let raw = value as? Enum.RawValue else {
            throw JSONDecodableError.IncompatibleTypeError(key: key, elementType: value.dynamicType, expectedType: Enum.RawValue.self)
        }
        guard let result = Enum(rawValue: raw) else {
            throw JSONDecodableError.IncompatibleTypeError(key: key, elementType: Enum.RawValue.self, expectedType: Enum.self)
        }
        return result
    }
    
    // [JSONCompatible]
    public func decode<Element: JSONCompatible>(key: String) throws -> [Element] {
        guard let value = get(key) else {
            throw JSONDecodableError.MissingTypeError(key: key)
        }
        guard let array = value as? [Element] else {
            throw JSONDecodableError.IncompatibleTypeError(key: key, elementType: value.dynamicType, expectedType: [Element].self)
        }
        return array
    }
    
    // [JSONCompatible]?
    public func decode<Element: JSONCompatible>(key: String) throws -> [Element]? {
        guard let value = get(key) else {
            return nil
        }
        guard let array = value as? [Element] else {
            throw JSONDecodableError.IncompatibleTypeError(key: key, elementType: value.dynamicType, expectedType: [Element].self)
        }
        return array
    }
    
    // [JSONDecodable]
    public func decode<Element: JSONDecodable>(key: String) throws -> [Element] {
        guard let value = get(key) else {
            return []
        }
        guard let array = value as? [JSONObject] else {
            throw JSONDecodableError.ArrayTypeExpectedError(key: key, elementType: value.dynamicType)
        }
        return try array.flatMap { try Element(object: $0)}
    }
    
    // [JSONDecodable]?
    public func decode<Element: JSONDecodable>(key: String) throws -> [Element]? {
        guard let value = get(key) else {
            return nil
        }
        guard let array = value as? [JSONObject] else {
            throw JSONDecodableError.ArrayTypeExpectedError(key: key, elementType: value.dynamicType)
        }
        return try array.flatMap { try Element(object: $0)}
    }
    
    // [Enum]
    public func decode<Enum: RawRepresentable>(key: String) throws -> [Enum] {
        guard let value = get(key) else {
            return []
        }
        guard let array = value as? [Enum.RawValue] else {
            throw JSONDecodableError.ArrayTypeExpectedError(key: key, elementType: value.dynamicType)
        }
        return array.flatMap { Enum(rawValue: $0) }
    }
    
    // [Enum]?
    public func decode<Enum: RawRepresentable>(key: String) throws -> [Enum]? {
        guard let value = get(key) else {
            return nil
        }
        guard let array = value as? [Enum.RawValue] else {
            throw JSONDecodableError.ArrayTypeExpectedError(key: key, elementType: value.dynamicType)
        }
        return array.flatMap { Enum(rawValue: $0) }
    }
    
    // [String:JSONCompatible]
    public func decode<Value: JSONCompatible>(key: String) throws -> [String: Value] {
        guard let value = get(key) else {
            throw JSONDecodableError.MissingTypeError(key: key)
        }
        guard let dictionary = value as? [String: Value] else {
            throw JSONDecodableError.IncompatibleTypeError(key: key, elementType: value.dynamicType, expectedType: [String: Value].self)
        }
        return dictionary
    }
    
    // [String:JSONCompatible]?
    public func decode<Value: JSONCompatible>(key: String) throws -> [String: Value]? {
        guard let value = get(key) else {
            return nil
        }
        guard let dictionary = value as? [String: Value] else {
            throw JSONDecodableError.IncompatibleTypeError(key: key, elementType: value.dynamicType, expectedType: [String: Value].self)
        }
        return dictionary
    }
    
    // JSONTransformable
    public func decode<EncodedType, DecodedType>(key: String, transformer: JSONTransformer<EncodedType, DecodedType>) throws -> DecodedType {
        guard let value = get(key) else {
            throw JSONDecodableError.MissingTypeError(key: key)
        }
        guard let actual = value as? EncodedType else {
            throw JSONDecodableError.IncompatibleTypeError(key: key, elementType: value.dynamicType, expectedType: EncodedType.self)
        }
        guard let result = transformer.decoding(actual) else {
            throw JSONDecodableError.TransformerFailedError(key: key)
        }
        return result
    }
    
    // JSONTransformable?
    public func decode<EncodedType, DecodedType>(key: String, transformer: JSONTransformer<EncodedType, DecodedType>) throws -> DecodedType? {
        guard let value = get(key) else {
            return nil
        }
        guard let actual = value as? EncodedType else {
            throw JSONDecodableError.IncompatibleTypeError(key: key, elementType: value.dynamicType, expectedType: EncodedType.self)
        }
        guard let result = transformer.decoding(actual) else {
            throw JSONDecodableError.TransformerFailedError(key: key)
        }
        return result
    }
}

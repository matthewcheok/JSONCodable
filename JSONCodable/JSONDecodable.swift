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
    init(JSONArray: [Any], filtered: Bool = false) throws {
        self.init(try JSONArray.flatMap {
            guard let json = $0 as? [String : Any] else {
                throw JSONDecodableError.dictionaryTypeExpectedError(key: "n/a", elementType: type(of: $0))
            }
            if filtered {
                return try? Element(object: json)
            } else {
                return try Element(object: json)
            }
        })
    }


}

// JSONDecoder - provides utility methods for decoding

public final class JSONDecoder {
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


    // JSONDecodable
    public func decode<Decodable: JSONDecodable>(_ key: String) throws -> Decodable {
        return try gettingTransforms(key: key, transform: Decodable.init)
    }
    
    // JSONDecodable?
    public func decode<Decodable: JSONDecodable>(_ key: String) throws -> Decodable? {
        return try gettingTransformsOptional(key: key, transform: Decodable.init)
    }

    
    // Enum
    public func decode<Enum: RawRepresentable>(_ key: String) throws -> Enum {
        guard let result = try decode(key) as Enum? else {
            throw JSONDecodableError.incompatibleTypeError(key: key, elementType: Enum.RawValue.self, expectedType: Enum.self)
        }
        return result
    }
    
    // Enum?
    public func decode<Enum: RawRepresentable>(_ key: String) throws -> Enum? {
        return try gettingTransformsOptional(key: key, transform: Enum.init)
    }
    
    // [JSONDecodable]
    public func decode<Element: JSONDecodable>(_ key: String, filter: Bool = false) throws -> [Element] {
        return try gettingTransforms(key: key, transform: { (preResult: [JSONObject]) in
            return try preResult.flatMap {
                if filter {
                    return try? Element(object: $0)
                } else {
                    return try Element(object: $0)
                }
            }
        })
    }
    
    // [JSONDecodable]?
    public func decode<Element: JSONDecodable>(_ key: String, filter: Bool = false) throws -> [Element]? {
        return try gettingTransformsOptional(key: key, transform: { (preResult: [JSONObject]) in
            return try preResult.flatMap {
                if filter {
                    return try? Element(object: $0)
                } else {
                    return try Element(object: $0)
                }
            }
        })
    }

    // [[JSONDecodable]]
    public func decode<Element: JSONDecodable>(_ key: String, filter: Bool = false) throws -> [[Element]] {
        return try gettingTransforms(key: key, transform: { (preResult: [[JSONObject]]) in
            return try preResult.map({ x in
                if filter {
                    return x.flatMap { try? Element(object: $0)}
                } else {
                    return try x.flatMap { try Element(object: $0)}
                }
            })
        })
    }
    
    // [Enum]
    public func decode<Enum: RawRepresentable>(_ key: String) throws -> [Enum] {
        return try gettingTransforms(key: key, transform: { (preResult: [Enum.RawValue]) in
            return preResult.map { Enum(rawValue: $0)! }
        })
    }
    
    // [Enum]?
    public func decode<Enum: RawRepresentable>(_ key: String) throws -> [Enum]? {
        return try gettingTransformsOptional(key: key, transform: { (preResult: [Enum.RawValue]) in
            return preResult.flatMap { Enum(rawValue: $0) }
        })
    }
    

    private func gettingTransforms<T, PreResult>(key: String, transform: (PreResult) throws -> T) throws -> T {
        guard let value = try gettingTransformsOptional(key: key, transform: transform) else {
            throw JSONDecodableError.missingTypeError(key: key)
        }
        
        return value
    }
    
    private func gettingTransformsOptional<T, PreResult>(key: String, transform: (PreResult) throws -> T?) throws -> T? {
        guard let value = get(key) else {
            return nil
        }
        if let t = value as? T {
            return t
        }
        guard let preResult = value as? PreResult else {
            throw JSONDecodableError.incompatibleTypeError(key: key, elementType: type(of: value), expectedType: PreResult.self)
        }
        return try transform(preResult)
    }
    
    // [String:JSONDecodable]
    public func decode<Element: JSONDecodable>(_ key: String) throws -> [String: Element] {
        return try gettingTransforms(key: key, transform: { (preResult: [String: JSONObject]) in
            var decoded = [String: Element]()
            try preResult.forEach {
                decoded[$0] = try Element(object: $1)
            }
            return decoded
        })
    }
    
    // [String:JSONDecodable]?
    public func decode<Element: JSONDecodable>(_ key: String) throws -> [String: Element]? {
        return try gettingTransformsOptional(key: key, transform: { (preResult: [String: JSONObject]) in
            var decoded = [String: Element]()
            try preResult.forEach {
                decoded[$0] = try Element(object: $1)
            }
            return decoded
        })
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

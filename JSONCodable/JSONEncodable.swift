//
//  JSONEncodable.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 17/7/15.
//  Copyright © 2015 matthewcheok. All rights reserved.
//

// Encoding Errors

public enum JSONEncodableError: ErrorType, CustomStringConvertible {
    case IncompatibleTypeError(
        elementType: Any.Type
    )
    case ArrayIncompatibleTypeError(
        elementType: Any.Type
    )
    case DictionaryIncompatibleTypeError(
        elementType: Any.Type
    )
    case ChildIncompatibleTypeError(
        key: String,
        elementType: Any.Type
    )
    case TransformerFailedError(
        key: String
    )
    
    public var description: String {
        switch self {
        case let .IncompatibleTypeError(elementType: elementType):
            return "JSONEncodableError: Incompatible type \(elementType)"
        case let .ArrayIncompatibleTypeError(elementType: elementType):
            return "JSONEncodableError: Got an array of incompatible type \(elementType)"
        case let .DictionaryIncompatibleTypeError(elementType: elementType):
            return "JSONEncodableError: Got an dictionary of incompatible type \(elementType)"
        case let .ChildIncompatibleTypeError(key: key, elementType: elementType):
            return "JSONEncodableError: Got incompatible type \(elementType) for key \(key)"
        case let .TransformerFailedError(key: key):
            return "JSONEncodableError: Transformer failed for key \(key)"
        }
    }
}

// Struct -> Dictionary

public protocol JSONEncodable {
    func toJSON() throws -> AnyObject
}

public extension JSONEncodable {
    func toJSON() throws -> AnyObject {
        let mirror = Mirror(reflecting: self)
        
        guard let style = mirror.displayStyle where style == .Struct || style == .Class else {
            throw JSONEncodableError.IncompatibleTypeError(elementType: self.dynamicType)
        }
        
        return try JSONEncoder.create({ (encoder) -> Void in
            // loop through all properties (instance variables)
            for (labelMaybe, valueMaybe) in mirror.children {
                guard let label = labelMaybe else {
                    continue
                }
                
                let value: Any
                
                // unwrap optionals
                if let v = valueMaybe as? JSONOptional {
                    guard let unwrapped = v.wrapped else {
                        continue
                    }
                    value = unwrapped
                }
                else {
                    value = valueMaybe
                }
                
                switch (value) {
                case let value as JSONEncodable:
                    try encoder.encode(value, key: label)
                case let value as JSONArray:
                    try encoder.encode(value, key: label)
                case let value as JSONDictionary:
                    try encoder.encode(value, key: label)
                default:
                    throw JSONEncodableError.ChildIncompatibleTypeError(key: label, elementType: value.dynamicType)
                }
            }
        })
    }
}

public extension Array {//where Element: JSONEncodable {
    private var wrapped: [Any] { return self.map{$0} }
    
    public func toJSON() throws -> AnyObject {
        var results: [AnyObject] = []
        for item in self.wrapped {
            if let item = item as? JSONEncodable {
                results.append(try item.toJSON())
            }
            else {
                throw JSONEncodableError.ArrayIncompatibleTypeError(elementType: item.dynamicType)
            }
        }
        return results
    }
}

// Dictionary convenience methods

public extension Dictionary {//where Key: String, Value: JSONEncodable {
    public func toJSON() throws -> AnyObject {
        var result: [String: AnyObject] = [:]
        for (k, item) in self {
            if let item = item as? JSONEncodable {
                result[String(k)] = try item.toJSON()
            }
            else {
                throw JSONEncodableError.DictionaryIncompatibleTypeError(elementType: item.dynamicType)
            }
        }
        return result
    }
}

// JSONEncoder - provides utility methods for encoding

public class JSONEncoder {
    var object = JSONObject()
    
    public static func create(@noescape setup: (encoder: JSONEncoder) throws -> Void) rethrows -> JSONObject {
        let encoder = JSONEncoder()
        try setup(encoder: encoder)
        return encoder.object
    }
    
    /* 
    Note:
    There is some duplication because methods with generic constraints need to
    take a concrete type conforming to the constraint are unable to take a parameter
    typed to the protocol. Hence we need non-generic versions so we can cast from 
    Any to JSONEncodable in the default implementation for toJSON().
    */
    
    // JSONEncodable
    public func encode<Encodable: JSONEncodable>(value: Encodable, key: String) throws {
        let result = try value.toJSON()
        object[key] = result
    }
    private func encode(value: JSONEncodable, key: String) throws {
        let result = try value.toJSON()
        object[key] = result
    }

    // JSONEncodable?
    public func encode<Encodable: JSONEncodable>(value: Encodable?, key: String) throws {
        guard let actual = value else {
            return
        }
        let result = try actual.toJSON()
        object[key] = result
    }

    // Enum
    public func encode<Enum: RawRepresentable>(value: Enum, key: String) throws {
        guard let compatible = value.rawValue as? JSONCompatible else {
            return
        }
        let result = try compatible.toJSON()
        object[key] = result
    }
    
    // Enum?
    public func encode<Enum: RawRepresentable>(value: Enum?, key: String) throws {
        guard let actual = value else {
            return
        }
        guard let compatible = actual.rawValue as? JSONCompatible else {
            return
        }
        let result = try compatible.toJSON()
        object[key] = result
    }
    
    // [JSONEncodable]
    public func encode<Encodable: JSONEncodable>(array: [Encodable], key: String) throws {
        guard array.count > 0 else {
            return
        }
        let result = try array.toJSON()
        object[key] = result
    }
    public func encode(array: [JSONEncodable], key: String) throws {
        guard array.count > 0 else {
            return
        }
        let result = try array.toJSON()
        object[key] = result
    }
    private func encode(array: JSONArray, key: String) throws {
        guard array.count > 0 && array.elementsAreJSONEncodable() else {
            return
        }
        let encodable = array.elementsMadeJSONEncodable()
        let result = try encodable.toJSON()
        object[key] = result
    }
    
    // [JSONEncodable]?
    public func encode<Encodable: JSONEncodable>(value: [Encodable]?, key: String) throws {
        guard let actual = value else {
            return
        }
        guard actual.count > 0 else {
            return
        }
        let result = try actual.toJSON()
        object[key] = result
    }
    
    // [Enum]
    public func encode<Enum: RawRepresentable>(value: [Enum], key: String) throws {
        guard value.count > 0 else {
            return
        }
        let result = try value.flatMap {
            try ($0.rawValue as? JSONCompatible)?.toJSON()
        }
        object[key] = result
    }
    
    // [Enum]?
    public func encode<Enum: RawRepresentable>(value: [Enum]?, key: String) throws {
        guard let actual = value else {
            return
        }
        guard actual.count > 0 else {
            return
        }
        let result = try actual.flatMap {
            try ($0.rawValue as? JSONCompatible)?.toJSON()
        }
        object[key] = result
    }
    
    // [String:JSONEncodable]
    public func encode<Encodable: JSONEncodable>(dictionary: [String:Encodable], key: String) throws {
        guard dictionary.count > 0 else {
            return
        }
        let result = try dictionary.toJSON()
        object[key] = result
    }
    public func encode(dictionary: [String:JSONEncodable], key: String) throws {
        guard dictionary.count > 0 else {
            return
        }
        let result = try dictionary.toJSON()
        object[key] = result
    }
    private func encode(dictionary: JSONDictionary, key: String) throws {
        guard dictionary.count > 0 && dictionary.valuesAreJSONEncodable() else {
            return
        }
        let encodable = dictionary.valuesMadeJSONEncodable()
        let result = try encodable.toJSON()
        object[key] = result
    }
    
    // [String:JSONEncodable]?
    public func encode<Encodable: JSONEncodable>(value: [String:Encodable]?, key: String) throws {
        guard let actual = value else {
            return
        }
        guard actual.count > 0 else {
            return
        }
        let result = try actual.toJSON()
        object[key] = result
    }
    
    // JSONTransformable
    public func encode<EncodedType, DecodedType>(value: DecodedType, key: String, transformer: JSONTransformer<EncodedType, DecodedType>) throws {
        guard let result = transformer.encoding(value) else {
            throw JSONEncodableError.TransformerFailedError(key: key)
        }
        object[key] = (result as! AnyObject)
    }
    
    // JSONTransformable?
    public func encode<EncodedType, DecodedType>(value: DecodedType?, key: String, transformer: JSONTransformer<EncodedType, DecodedType>) throws {
        guard let actual = value else {
            return
        }
        guard let result = transformer.encoding(actual) else {
            return
        }
        object[key] = (result as! AnyObject)
    }
}

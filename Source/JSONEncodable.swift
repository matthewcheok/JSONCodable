//
//  JSONEncodable.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 17/7/15.
//  Copyright © 2015 matthewcheok. All rights reserved.
//

// Encoding Errors

public enum JSONEncodableError: Error, CustomStringConvertible {
    case incompatibleTypeError(
        elementType: Any.Type
    )
    case arrayIncompatibleTypeError(
        elementType: Any.Type
    )
    case dictionaryIncompatibleTypeError(
        elementType: Any.Type
    )
    case childIncompatibleTypeError(
        key: String,
        elementType: Any.Type
    )
    case transformerFailedError(
        key: String
    )

    public var description: String {
        switch self {
        case let .incompatibleTypeError(elementType: elementType):
            return "JSONEncodableError: Incompatible type \(elementType)"
        case let .arrayIncompatibleTypeError(elementType: elementType):
            return "JSONEncodableError: Got an array of incompatible type \(elementType)"
        case let .dictionaryIncompatibleTypeError(elementType: elementType):
            return "JSONEncodableError: Got an dictionary of incompatible type \(elementType)"
        case let .childIncompatibleTypeError(key: key, elementType: elementType):
            return "JSONEncodableError: Got incompatible type \(elementType) for key \(key)"
        case let .transformerFailedError(key: key):
            return "JSONEncodableError: Transformer failed for key \(key)"
        }
    }
}

// Struct -> Dictionary

public protocol JSONEncodable {
    func toJSON() throws -> Any
}

public extension JSONEncodable {

    func toJSON() throws -> Any {
        let mirror = Mirror(reflecting: self)

        #if !swift(>=3.0)
            guard let style = mirror.displayStyle where style == .Struct || style == .Class else {
            throw JSONEncodableError.IncompatibleTypeError(elementType: self.dynamicType)
            }
        #else

            guard let style = mirror.displayStyle , style == .`struct` || style == .`class` else {
                throw JSONEncodableError.incompatibleTypeError(elementType: type(of: self))
            }
        #endif

        return try JSONEncoder.create { encoder in
            // loop through all properties (instance variables)
            for (labelMaybe, valueMaybe) in mirror.getAllProperties() {
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
                    throw JSONEncodableError.childIncompatibleTypeError(key: label, elementType: type(of: value))
                }

            }
        }
    }
}



public extension Array { //where Element: JSONEncodable {
    private var wrapped: [Any] { return self.map{$0} }

    public func toJSON() throws -> Any {
        var results: [Any] = []
        for item in self.wrapped {
            if let item = item as? JSONEncodable {
                results.append(try item.toJSON())
            }
            else {
                throw JSONEncodableError.arrayIncompatibleTypeError(elementType: type(of: item))
            }
        }
        return results
    }
}

// Dictionary convenience methods

public extension Dictionary {//where Key: String, Value: JSONEncodable {
    public func toJSON() throws -> Any {
        var result: [String: Any] = [:]
        for (k, item) in self {
            if let item = item as? JSONEncodable {
                result[String(describing:k)] = try item.toJSON()
            }
            else {
                throw JSONEncodableError.dictionaryIncompatibleTypeError(elementType: type(of: item))
            }
        }
        return result
    }
}

// JSONEncoder - provides utility methods for encoding

public class JSONEncoder {
    var object = JSONObject()

    public static func create(_ setup: (_ encoder: JSONEncoder) throws -> Void) rethrows -> JSONObject {
        let encoder = JSONEncoder()
        try setup(encoder)
        return encoder.object
    }

    private func update(object: JSONObject, keys: [String], value: Any) -> JSONObject {
        if keys.isEmpty {
            return object
        }
        var newObject = object
        var newKeys = keys

        let firstKey = newKeys.removeFirst()

        if newKeys.count > 0 {
            let innerObject = object[firstKey] as? JSONObject ?? JSONObject()
            newObject[firstKey] = update(object: innerObject, keys: newKeys, value: value)
        } else {
            newObject[firstKey] = value
        }
        return newObject
    }

    /*
     Note:
     There is some duplication because methods with generic constraints need to
     take a concrete type conforming to the constraint are unable to take a parameter
     typed to the protocol. Hence we need non-generic versions so we can cast from
     Any to JSONEncodable in the default implementation for toJSON().
     */

    // JSONEncodable
    public func encode<Encodable: JSONEncodable>(_ value: Encodable, key: String) throws {
        let result = try value.toJSON()
        object = update(object: object, keys: key.components(separatedBy: "."), value: result)
    }

    fileprivate func encode(_ value: JSONEncodable, key: String) throws {
        let result = try value.toJSON()
        object = update(object: object, keys: key.components(separatedBy: "."), value: result)
    }

    // JSONEncodable?
    public func encode(_ value: JSONEncodable?, key: String) throws {
        guard let actual = value else {
            return
        }
        let result = try actual.toJSON()
        object = update(object: object, keys: key.components(separatedBy: "."), value: result)
    }

    // Enum
    public func encode<Enum: RawRepresentable>(_ value: Enum, key: String) throws {
        guard let compatible = value.rawValue as? JSONCompatible else {
            return
        }
        let result = try compatible.toJSON()
        object = update(object: object, keys: key.components(separatedBy: "."), value: result)
    }

    // Enum?
    public func encode<Enum: RawRepresentable>(_ value: Enum?, key: String) throws {
        guard let actual = value else {
            return
        }
        guard let compatible = actual.rawValue as? JSONCompatible else {
            return
        }
        let result = try compatible.toJSON()
        object = update(object: object, keys: key.components(separatedBy: "."), value: result)
    }

    // [JSONEncodable]
    public func encode<Encodable: JSONEncodable>(_ array: [Encodable], key: String) throws {
        let result = try array.toJSON()
        object = update(object: object, keys: key.components(separatedBy: "."), value: result)
    }
    public func encode(_ array: [JSONEncodable], key: String) throws {
        let result = try array.toJSON()
        object = update(object: object, keys: key.components(separatedBy: "."), value: result)
    }

    fileprivate func encode(_ array: JSONArray, key: String) throws {
        guard array.elementsAreJSONEncodable() else {
            throw JSONEncodableError
                .childIncompatibleTypeError(key: key,
                                            elementType: array.elementType)
        }
        let encodable = array.elementsMadeJSONEncodable()
        let result = try encodable.toJSON()
        object = update(object: object, keys: key.components(separatedBy: "."), value: result)
    }

    // [JSONEncodable]?
    public func encode<Encodable: JSONEncodable>(_ value: [Encodable]?, key: String) throws {
        guard let actual = value else {
            return
        }
        let result = try actual.toJSON()
        object = update(object: object, keys: key.components(separatedBy: "."), value: result)
    }

    // [Enum]
    public func encode<Enum: RawRepresentable>(_ value: [Enum], key: String) throws {
        let result = try value.flatMap {
            try ($0.rawValue as? JSONCompatible)?.toJSON()
        }
        object = update(object: object, keys: key.components(separatedBy: "."), value: result)
    }

    // [Enum]?
    public func encode<Enum: RawRepresentable>(_ value: [Enum]?, key: String) throws {
        guard let actual = value else {
            return
        }
        let result = try actual.flatMap {
            try ($0.rawValue as? JSONCompatible)?.toJSON()
        }
        object = update(object: object, keys: key.components(separatedBy: "."), value: result)
    }

    // [String:JSONEncodable]
    public func encode<Encodable: JSONEncodable>(_ dictionary: [String:Encodable], key: String) throws {
        let result = try dictionary.toJSON()
        object = update(object: object, keys: key.components(separatedBy: "."), value: result)
    }
    public func encode(_ dictionary: [String:JSONEncodable], key: String) throws {
        let result = try dictionary.toJSON()
        object[key] = result
    }
    fileprivate func encode(_ dictionary: JSONDictionary, key: String) throws {
        guard dictionary.valuesAreJSONEncodable() else {
            throw JSONEncodableError
                .childIncompatibleTypeError(key: key,
                                            elementType: dictionary.valueType)
        }
        let encodable = dictionary.valuesMadeJSONEncodable()
        let result = try encodable.toJSON()
        object = update(object: object, keys: key.components(separatedBy: "."), value: result)
    }

    // [String:JSONEncodable]?
    public func encode<Encodable: JSONEncodable>(_ value: [String:Encodable]?, key: String) throws {
        guard let actual = value else {
            return
        }
        let result = try actual.toJSON()
        object = update(object: object, keys: key.components(separatedBy: "."), value: result)
    }

    // JSONTransformable
    public func encode<EncodedType, DecodedType>(_ value: DecodedType, key: String, transformer: JSONTransformer<EncodedType, DecodedType>) throws {
        guard let result = transformer.encoding(value) else {
            throw JSONEncodableError.transformerFailedError(key: key)
        }
        object = update(object: object, keys: key.components(separatedBy: "."), value: result)
    }

    // JSONTransformable?
    public func encode<EncodedType, DecodedType>(_ value: DecodedType?, key: String, transformer: JSONTransformer<EncodedType, DecodedType>) throws {
        guard let actual = value else {
            return
        }
        guard let result = transformer.encoding(actual) else {
            return
        }
        object = update(object: object, keys: key.components(separatedBy: "."), value: result)
    }
}

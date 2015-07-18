//
//  JSONDecodable.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 17/7/15.
//  Copyright © 2015 matthewcheok. All rights reserved.
//

// error type

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
    init?(JSONDictionary: [String : AnyObject])
}

public extension Array where Element: JSONDecodable {
    init(JSONArray: [AnyObject]) {
        self.init(JSONArray.flatMap {
            guard let json = $0 as? [String : AnyObject] else {
                return nil
            }
            return Element(JSONDictionary: json)
            })
    }
}

// Dictionary convenience methods

public extension Dictionary where Value: AnyObject {
    // TODO: validate array elements
    // optional array of decodables
    public func decode<Element: JSONDecodable>(key: Key) throws -> [Element]? {
        if let y = self[key] {
            guard let x = y as? [[String : AnyObject]] else {
                throw JSONDecodableError.ArrayTypeExpectedError(key: key as! String, elementType: y.dynamicType)
            }
            return x.flatMap {Element(JSONDictionary: $0)}
        }
        return nil
    }
    
    // required array of decodables
    public func decode<Element: JSONDecodable>(key: Key) throws -> [Element] {
        guard let y = self[key] else {
            return []
        }
        guard let x = y as? [[String : AnyObject]] else {
            throw JSONDecodableError.ArrayTypeExpectedError(key: key as! String, elementType: y.dynamicType)
        }
        return x.flatMap {Element(JSONDictionary: $0)}
    }
    
    // optional array of scalars
    public func decode<Element: JSONCompatible>(key: Key) throws -> [Element]? {
        if let y = self[key] {
            guard let x = y as? [Element] else {
                throw JSONDecodableError.IncompatibleTypeError(key: key as! String, elementType: y.dynamicType, expectedType: [Element].self)
            }
            return x
        }
        return nil
    }
    
    // required array of scalars
    public func decode<Element: JSONCompatible>(key: Key) throws -> [Element] {
        guard let y = self[key] else {
            throw JSONDecodableError.MissingTypeError(key: key as! String)
        }
        guard let x = y as? [Element] else {
            throw JSONDecodableError.IncompatibleTypeError(key: key as! String, elementType: y.dynamicType, expectedType: [Element].self)
        }
        return x
    }
    
    // optional decodable
    public func decode<Type: JSONDecodable>(key: Key) throws -> Type? {
        if let y = self[key] {
            guard let x = y as? [String : AnyObject] else {
                throw JSONDecodableError.DictionaryTypeExpectedError(key: key as! String, elementType: y.dynamicType)
            }
            return Type(JSONDictionary: x)
        }
        return nil
    }
    
    // required decodable
    public func decode<Type: JSONDecodable>(key: Key) throws -> Type {
        guard let y = self[key] else {
            throw JSONDecodableError.MissingTypeError(key: key as! String)
        }
        guard let x = y as? [String : AnyObject] else {
            throw JSONDecodableError.DictionaryTypeExpectedError(key: key as! String, elementType: y.dynamicType)
        }
        guard let value = Type(JSONDictionary: x) else {
            throw JSONDecodableError.IncompatibleTypeError(key: key as! String, elementType: y.dynamicType, expectedType: Type.self)
        }
        return value
    }
    
    // optional scalar
    public func decode<Type: JSONCompatible>(key: Key) throws -> Type? {
        return self[key] as? Type
    }
    
    // required scalar
    public func decode<Type: JSONCompatible>(key: Key) throws -> Type {
        guard let y = self[key] else {
            throw JSONDecodableError.MissingTypeError(key: key as! String)
        }
        guard let x = y as? Type else {
            throw JSONDecodableError.IncompatibleTypeError(key: key as! String, elementType: y.dynamicType, expectedType: Type.self)
        }
        return x
    }
    
    // optional transformable
    public func decode<DecodedType, EncodedType>(key: Key, transformer: JSONTransformer<EncodedType, DecodedType>) throws -> DecodedType? {
        if let y = self[key] {
            guard let x = y as? EncodedType else {
                throw JSONDecodableError.IncompatibleTypeError(key: key as! String, elementType: y.dynamicType, expectedType: EncodedType.self)
            }
            guard let z = transformer.decoding(x) else {
                throw JSONDecodableError.TransformerFailedError(key: key as! String)
            }
            
            return z
        }
        return nil
    }
    
    // required transformable
    public func decode<DecodedType, EncodedType>(key: Key, transformer: JSONTransformer<EncodedType, DecodedType>) throws -> DecodedType {
        guard let y = self[key] else {
            throw JSONDecodableError.MissingTypeError(key: key as! String)
        }
        guard let x = y as? EncodedType else {
            throw JSONDecodableError.IncompatibleTypeError(key: key as! String, elementType: y.dynamicType, expectedType: EncodedType.self)
        }
        guard let z = transformer.decoding(x) else {
            throw JSONDecodableError.TransformerFailedError(key: key as! String)
        }
        
        return z
    }
}
//
//  JSONEncodable.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 17/7/15.
//  Copyright © 2015 matthewcheok. All rights reserved.
//

// Error type

public enum JSONEncodableError: ErrorType, CustomStringConvertible {
    case IncompatibleTypeError(elementType: Any.Type)
    case ArrayIncompatibleTypeError(elementType: Any.Type)
    case ChildIncompatibleTypeError(key: String, elementType: Any.Type)
    case TransformerFailedError(
        key: String
    )
    
    public var description: String {
        switch self {
        case let .IncompatibleTypeError(elementType: elementType):
            return "JSONEncodableError: Incompatible type \(elementType)"
        case let .ArrayIncompatibleTypeError(elementType: elementType):
            return "JSONEncodableError: Got an array of incompatible type \(elementType)"
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
        
        // loop through all properties (instance variables)
        var result: [String: AnyObject] = [:]
        for (labelMaybe, valueMaybe) in mirror.children {
            guard let label = labelMaybe else {
                continue
            }
            
            try result.encode(valueMaybe, key: label)
        }
        
        return result
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

public extension Dictionary where Value: AnyObject {
    public mutating func encode(valueMaybe: Any, key: Key) throws {
        let value: Any
        
        // unwrap optionals
        if let v = valueMaybe as? JSONOptional {
            guard let unwrapped = v.wrapped else {
                return
            }
            value = unwrapped
        }
        else {
            value = valueMaybe
        }
        
        // test for array
        if let array = value as? JSONArray {
            if array.count > 0 && array.elementsAreJSONEncodable() {
                let encodableArray = array.elementsMadeJSONEncodable()
                let result = try encodableArray.toJSON()
                self[key] = (result as! Value)
            }
        }
            
        // test for compatible type
        else if let compatible = value as? JSONEncodable {
            let result = try compatible.toJSON()
            self[key] = (result as! Value)
        }
            
        // incompatible type
        else {
            throw JSONEncodableError.ChildIncompatibleTypeError(key: key as! String, elementType: value.dynamicType)
        }
    }
    
    // optional transformable
    public mutating func encode<EncodedType, DecodedType>(value: DecodedType?, key: Key, transformer: JSONTransformer<EncodedType, DecodedType>) throws {
        if let value = value {
            let encodedValue = transformer.encoding(value)
            try encode(encodedValue, key: key)
        }
    }
    
    // required transformable
    public mutating func encode<EncodedType, DecodedType>(value: DecodedType, key: Key, transformer: JSONTransformer<EncodedType, DecodedType>) throws {
        guard let encodedValue = transformer.encoding(value) else {
            throw JSONEncodableError.TransformerFailedError(key: key as! String)
        }
        
        try encode(encodedValue, key: key)
    }
}
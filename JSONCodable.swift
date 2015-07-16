import Foundation

// convenience protocol

public protocol JSONCodable: JSONEncodable, JSONDecodable {}

// error types

public enum JSONEncodableError: ErrorType {
    case IncompatibleTypeError(elementType: Any.Type)
    case ArrayIncompatibleTypeError(elementType: Any.Type)
    case ChildIncompatibleTypeError(key: String, elementType: Any.Type)

    public var description: String {
        switch self {
        case let .IncompatibleTypeError(elementType: elementType):
            return "JSONEncodableError: Incompatible type \(elementType)"
        case let .ArrayIncompatibleTypeError(elementType: elementType):
            return "JSONEncodableError: Got an array of incompatible type \(elementType)"
        case let .ChildIncompatibleTypeError(key: key, elementType: elementType):
            return "JSONEncodableError: Got incompatible type \(elementType) for key \(key)"
        }
    }
}

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
        }
    }
}

// optional handling

private protocol JSONOptional {
    var wrapped: Any? { get }
}

extension Optional : JSONOptional {
    var wrapped: Any? { return self }
}

// JSONCompatible - valid types in JSON

public protocol JSONCompatible: JSONEncodable {}
extension JSONCompatible {
    public func JSONEncode() throws -> AnyObject {
        return self as! AnyObject
    }
}

extension String: JSONCompatible {}
extension Double: JSONCompatible {}
extension Float: JSONCompatible {}
extension Bool: JSONCompatible {}
extension Int: JSONCompatible {}

// JSONArchive - Dictionary convenience methods

public protocol JSONArchive {}

extension Dictionary: JSONArchive {
    public mutating func archive(valueMaybe: Any, key: Key) throws {
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

        // test for compatible type
        if let value = value as? JSONEncodable {
            let result = try value.JSONEncode()
            self[key] = (result as! Value)
        }

            // incompatible type
        else {
            throw JSONEncodableError.ChildIncompatibleTypeError(key: key as! String, elementType: value.dynamicType)
        }
    }

    // TODO: validate array elements
    // optional array of decodables
    public func restore<Element: JSONDecodable>(key: Key) throws -> [Element]? {
        if let y = self[key] {
            guard let x = y as? [[String: AnyObject]] else {
                throw JSONDecodableError.ArrayTypeExpectedError(key: key as! String, elementType: y.dynamicType)
            }
            return x.flatMap {Element(JSONDictionary: $0)}
        }
        return nil
    }

    // required array of decodables
    public func restore<Element: JSONDecodable>(key: Key) throws -> [Element] {
        guard let y = self[key] else {
            return []
        }
        guard let x = y as? [[String: AnyObject]] else {
            throw JSONDecodableError.ArrayTypeExpectedError(key: key as! String, elementType: y.dynamicType)
        }
        return x.flatMap {Element(JSONDictionary: $0)}
    }

    // optional array of scalars
    public func restore<Element: JSONCompatible>(key: Key) throws -> [Element]? {
        if let y = self[key] {
            guard let x = y as? [Element] else {
                throw JSONDecodableError.IncompatibleTypeError(key: key as! String, elementType: y.dynamicType, expectedType: [Element].self)
            }
            return x
        }
        return nil
    }

    // required array of scalars
    public func restore<Element: JSONCompatible>(key: Key) throws -> [Element] {
        guard let y = self[key] else {
            throw JSONDecodableError.MissingTypeError(key: key as! String)
        }
        guard let x = y as? [Element] else {
            throw JSONDecodableError.IncompatibleTypeError(key: key as! String, elementType: y.dynamicType, expectedType: [Element].self)
        }
        return x
    }

    // optional decodable
    public func restore<Type: JSONDecodable>(key: Key) throws -> Type? {
        if let y = self[key] {
            guard let x = y as? [String: AnyObject] else {
                throw JSONDecodableError.DictionaryTypeExpectedError(key: key as! String, elementType: y.dynamicType)
            }
            return Type(JSONDictionary: x)
        }
        return nil
    }

    // required decodable
    public func restore<Type: JSONDecodable>(key: Key) throws -> Type {
        guard let y = self[key] else {
            throw JSONDecodableError.MissingTypeError(key: key as! String)
        }
        guard let x = y as? [String: AnyObject] else {
            throw JSONDecodableError.DictionaryTypeExpectedError(key: key as! String, elementType: y.dynamicType)
        }
        guard let value = Type(JSONDictionary: x) else {
            throw JSONDecodableError.IncompatibleTypeError(key: key as! String, elementType: y.dynamicType, expectedType: Type.self)
        }
        return value
    }

    // optional scalar
    public func restore<Type: JSONCompatible>(key: Key) throws -> Type? {
        return self[key] as? Type
    }

    // required scalar
    public func restore<Type: JSONCompatible>(key: Key) throws -> Type {
        guard let y = self[key] else {
            throw JSONDecodableError.MissingTypeError(key: key as! String)
        }
        guard let x = y as? Type else {
            throw JSONDecodableError.IncompatibleTypeError(key: key as! String, elementType: y.dynamicType, expectedType: Type.self)
        }
        return x
    }
}

// JSONEncodable: Struct -> Dictionary

public protocol JSONEncodable {
    func JSONEncode() throws -> AnyObject
    func JSONString() throws -> String
}

extension Array: JSONEncodable {
    private var wrapped: [Any] { return self.map{$0} }

    public func JSONEncode() throws -> AnyObject {
        var results: [AnyObject] = []
        for item in self.wrapped {
            if let item = item as? JSONEncodable {
                results.append(try item.JSONEncode())
            }
            else {
                throw JSONEncodableError.ArrayIncompatibleTypeError(elementType: item.dynamicType)
            }
        }
        return results
    }
}

public extension JSONEncodable {
    func JSONEncode() throws -> AnyObject {
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

            try result.archive(valueMaybe, key: label)
        }

        return result
    }

    public func JSONString() throws -> String {
        let json = try JSONEncode()
        let data = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions(rawValue: 0))
        guard let string = NSString(data: data, encoding: NSUTF8StringEncoding) else {
            return ""
        }
        return string as String
    }
}

// JSONDecodable: Dictionary -> Struct

public protocol JSONDecodable {
    init?(JSONDictionary: [String: AnyObject])
    init?(JSONString: String)
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
    init(JSONArray: [[String: AnyObject]]) {
        self.init(JSONArray.flatMap {Element(JSONDictionary: $0)})
    }

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

        guard let converted = result as? [[String: AnyObject]] else {
            return nil
        }

        self.init(JSONArray: converted)
    }
}


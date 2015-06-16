import Foundation

// convenience protocol

public protocol JSONCodable: JSONEncodable, JSONDecodable {}

// error types

public enum JSONEncodableError: ErrorType {
    case IncompatibleTypeError(type: Any)
    case ArrayIncompatibleTypeError(elementType: Any)
    case ChildIncompatibleTypeError(label: String, elementType: Any)
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
            throw JSONEncodableError.ChildIncompatibleTypeError(label: key as! String, elementType: value.dynamicType)
        }
    }

    public func restore<T: JSONDecodable>(inout array: [T]?, key: Key) {
        if let json = self[key] as? [[String: AnyObject]] {
            array = json.map {T(JSONDictionary: $0)}
        }
    }

    public func restore<T: JSONDecodable>(inout array: [T], key: Key) {
        if let json = self[key] as? [[String: AnyObject]] {
            array = json.map {T(JSONDictionary: $0)}
        }
    }

    public func restore<T: JSONDecodable>(inout thing: T?, key: Key) {
        if let x = self[key] as? [String: AnyObject] {
            thing = T(JSONDictionary: x)
        }
    }

    public func restore<T: JSONDecodable>(inout thing: T, key: Key) {
        if let x = self[key] as? [String: AnyObject] {
            thing = T(JSONDictionary: x)
        }
    }

    public func restore<T: JSONCompatible>(inout value: T?, key: Key) {
        if let x = self[key] as? T {
            value = x
        }
    }

    public func restore<T: JSONCompatible>(inout value: T, key: Key) {
        if let x = self[key] as? T {
            value = x
        }
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
            throw JSONEncodableError.IncompatibleTypeError(type: self.dynamicType)
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
    init()
    init(JSONDictionary: [String: AnyObject])
    init?(JSONString: String)

    mutating func JSONDecode(JSONDictionary: [String: AnyObject])
}

public extension JSONDecodable {
    init(JSONDictionary: [String: AnyObject]) {
        self.init()
        JSONDecode(JSONDictionary)
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

        guard let converted = result as? [String: AnyObject] else {
            return nil
        }
        self.init(JSONDictionary: converted)
    }
}

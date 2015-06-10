import Foundation

public enum JSONEncodableError: ErrorType {
    case IncompatibleTypeError(type: Any)
    case ArrayIncompatibleTypeError(elementType: Any)
    case ChildIncompatibleTypeError(label: String, elementType: Any)
}

private protocol JSONOptional {
    var wrapped: Any? { get }
}

extension Optional : JSONOptional {
    var wrapped: Any? { return self }
}

public protocol JSONEncodable {
    func JSONEncoded() throws -> AnyObject
}

extension Array: JSONEncodable {
    private var wrapped: [Any] { return self.map{$0} }
    
    public func JSONEncoded() throws -> AnyObject {
        var results: [AnyObject] = []
        for item in self.wrapped {
            if let item = item as? JSONEncodable {
                results.append(try item.JSONEncoded())
            }
            else {
                throw JSONEncodableError.ArrayIncompatibleTypeError(elementType: item.dynamicType)
            }
        }
        return results
    }
}

extension String: JSONEncodable {
    public func JSONEncoded() throws -> AnyObject {
        return self
    }
}

extension Double: JSONEncodable {
    public func JSONEncoded() throws -> AnyObject {
        return self
    }
}

extension Float: JSONEncodable {
    public func JSONEncoded() throws -> AnyObject {
        return self
    }
}

extension Int: JSONEncodable {
    public func JSONEncoded() throws -> AnyObject {
        return self
    }
}

extension Bool: JSONEncodable {
    public func JSONEncoded() throws -> AnyObject {
        return self
    }
}

public extension JSONEncodable {
    func JSONEncoded() throws -> AnyObject {
        let mirror = Mirror(reflecting: self)
        
        guard let style = mirror.displayStyle where style == .Struct else {
            throw JSONEncodableError.IncompatibleTypeError(type: self.dynamicType)
        }
        
        // loop through all properties (instance variables)
        var result: [String: AnyObject] = [:]
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
            
            // test for compatible type
            if let value = value as? JSONEncodable {
                result[label] = try value.JSONEncoded()
            }
                
            // incompatible type
            else {
                throw JSONEncodableError.ChildIncompatibleTypeError(label: label, elementType: value.dynamicType)
            }
        
        }
        
        return result
    }
}
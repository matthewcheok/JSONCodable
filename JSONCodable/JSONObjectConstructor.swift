//
//  JSONObjectConstructor.swift
//  JSONCodable
//
//  Created by FoxRichard on 12/18/16.
//
//

import Foundation

public protocol JSONObjectDecodable: JSONDecodable {
    static func construct(from object: JSONObject) throws -> Self
}

extension JSONObjectDecodable where Self: AnyObject {
    public init(object: JSONObject) throws {
        self = try Self.construct(from: object)
    }
}

public func DecodableCastAs<T>(object: Any) -> T {
    return object as! T
}

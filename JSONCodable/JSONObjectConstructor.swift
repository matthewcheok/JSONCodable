//
//  JSONObjectConstructor.swift
//  JSONCodable
//
//  Created by FoxRichard on 12/18/16.
//
//

import Foundation

public protocol JSONObjDecodable: JSONDecodable {
    static func jsonConstruct(object: JSONObject) throws -> Self
}

extension JSONObjDecodable where Self: AnyObject {
    public init(object: JSONObject) throws {
        self = try Self.jsonConstruct(object: object)
    }
}

public func DecodableCastAs<T>(object: Any) -> T {
    return object as! T
}

//
//  JSONCodable.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 17/7/15.
//  Copyright © 2015 matthewcheok. All rights reserved.
//

// convenience protocol

public protocol JSONCodable: JSONEncodable, JSONCompatible {}

// JSONCompatible - valid types in JSON

public protocol JSONCompatible: JSONEncodable {}

extension String: JSONDecodable, JSONCompatible {
    public init(object: JSONObject) throws {
        fatalError()
    }
}
extension Double: JSONDecodable, JSONCompatible {
    public init(object: JSONObject) throws {
        fatalError()
    }
}
extension Bool: JSONDecodable, JSONCompatible {
    public init(object: JSONObject) throws {
        fatalError()
    }
}
extension Int: JSONDecodable, JSONCompatible {
    public init(object: JSONObject) throws {
        fatalError()
    }
}

extension JSONCompatible {
  public func toJSON() throws -> Any {
    return self
  }
}

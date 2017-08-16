//
//  JSONCodable.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 17/7/15.
//  Copyright © 2015 matthewcheok. All rights reserved.
//

// JSONCompatible - valid types in JSON

public protocol JSONCompatible: JSONEncodable {}

extension String: JSONCompatible {}
extension Double: JSONCompatible {}
extension Float: JSONCompatible {}
extension Bool: JSONCompatible {}
extension Int: JSONCompatible {}

extension JSONCompatible {
  public func toJSON() throws -> Any {
    return self
  }
}

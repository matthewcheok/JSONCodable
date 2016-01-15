//
//  Fruit.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 13/10/15.
//
//

import Foundation
import JSONCodable

enum FruitColor: String {
    case Red
    case Blue
}

struct Fruit: Equatable {
    let name: String
    let color: FruitColor
}

func ==(lhs: Fruit, rhs: Fruit) -> Bool {
    return lhs.name == rhs.name && lhs.color == rhs.color
}

extension Fruit: JSONCodable {
    init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        name = try decoder.decode("name")
        color = try decoder.decode("color")
    }
    
    func toJSON(options: JSONEncodingOptions) throws -> AnyObject {
        return try JSONEncoder.create(options) { (encoder) -> Void in
            NSLog("a")
            try encoder.encode(name, key: "name")
            NSLog("b")
            try encoder.encode(color, key: "color")
            NSLog("c")
        }
    }
}
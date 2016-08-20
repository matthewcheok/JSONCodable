//
//  Food.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 18/10/15.
//
//

import JSONCodable

enum Cuisine: String {
    case Mexican
    case Italian
    case German
    case French
    case Pizza
    case Barbecue
    case Chinese
    case Japanese
    case Korean
    case Thai
}

struct Food: Equatable {
    let name: String
    let cuisines: [Cuisine]
}

func ==(lhs: Food, rhs: Food) -> Bool {
    return lhs.name == rhs.name && lhs.cuisines == rhs.cuisines
}

extension Food: JSONCodable {
    init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        name = try decoder.decode("name")
        cuisines = try decoder.decode("cuisines")
    }
    
    func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(name, key: "name")
            try encoder.encode(cuisines, key: "cuisines")
        })
    }
}

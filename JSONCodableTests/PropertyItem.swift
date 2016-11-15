//
//  PropertyItem.swift
//  JSONCodable
//
//  Created by Richard Fox on 6/19/16.
//
//

import JSONCodable

struct PropertyItem {
    let name: String
    let long: Double
    let lat: Double
    let rel: String
    let type: String
}

extension PropertyItem: JSONDecodable {
    init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        rel = try decoder.decode("rel")
        type = try decoder.decode("class")
        name = try decoder.decode("properties.name")
        long = try decoder.decode("properties.location.coord.long")
        lat = try decoder.decode("properties.location.coord.lat")
    }
}

extension PropertyItem: JSONEncodable {
    func toJSON() throws -> Any {
        return try JSONEncoder.create { (encoder) -> Void in
            try encoder.encode(rel, key: "rel")
            try encoder.encode(type, key: "class")
            try encoder.encode(name, key: "properties.name")
            try encoder.encode(long, key: "properties.location.coord.long")
            try encoder.encode(lat, key: "properties.location.coord.lat")
        }
    }
}

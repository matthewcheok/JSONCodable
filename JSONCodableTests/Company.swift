//
//  Company.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 13/10/15.
//
//

import JSONCodable

struct Company: Equatable {
    let name: String
    var address: String?
}

func ==(lhs: Company, rhs: Company) -> Bool {
    return lhs.name == rhs.name && lhs.address == rhs.address
}

extension Company: JSONEncodable {}

extension Company: JSONDecodable {
    init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        name = try decoder.decode("name")
        address = try decoder.decode("address")
    }
}

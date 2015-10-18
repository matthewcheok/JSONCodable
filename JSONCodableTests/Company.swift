//
//  Company.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 13/10/15.
//
//

import Foundation
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
    init?(JSONDictionary: JSONObject) {
        let decoder = JSONDecoder(object: JSONDictionary)
        do {
            name = try decoder.decode("name")
            address = try decoder.decode("address")
        }
        catch {
            return nil
        }
    }
}
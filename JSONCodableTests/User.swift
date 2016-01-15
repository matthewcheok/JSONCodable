//
//  User.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 13/10/15.
//
//

import Foundation
import JSONCodable

struct User: Equatable {
    let id: Int
    let name: String
    var email: String?
    var company: Company?
    var friends: [User] = []    
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.email == rhs.email &&
        lhs.company == rhs.company &&
        lhs.friends == rhs.friends
}

extension User: JSONEncodable {
    func toJSON(encodeNulls encodeNulls: Bool) throws -> AnyObject {
        return try JSONEncoder.create({ (encoder) -> Void in
            encoder.encodeNullValues = encodeNulls
            try encoder.encode(id, key: "id")
            try encoder.encode(name, key: "full_name")
            try encoder.encode(email, key: "email")
            try encoder.encode(company, key: "company")
            try encoder.encode(friends, key: "friends")
        })
    }
}

extension User: JSONDecodable {
    init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)        
        id = try decoder.decode("id")
        name = try decoder.decode("full_name")
        email = try decoder.decode("email")
        company = try decoder.decode("company")
        friends = try decoder.decode("friends")
    }
}
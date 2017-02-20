//
//  User.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 13/10/15.
//
//

import JSONCodable

struct User: Equatable {
    let id: Int
    var likes: Int?
    let name: String
    var email: String?
    var company: Company?
    var friends: [User] = []
    var friendsLookup: [String: User]?
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.email == rhs.email &&
        lhs.company == rhs.company &&
        lhs.friends == rhs.friends
}

extension User: JSONEncodable {
    func toJSON() throws -> Any {
        return try JSONEncoder.create { (encoder) -> Void in
            try encoder.encode(id, key: "id")
            try encoder.encode(name, key: "full_name")
            try encoder.encode(email, key: "email")
            try encoder.encode(company, key: "company")
            try encoder.encode(friends, key: "friends")
            try encoder.encode(friendsLookup, key: "friendsLookup")
        }
    }
}

extension User: JSONDecodable {
    init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        id = try decoder.decode("id")
        likes = try decoder.decode("properties[0].likes")
        name = try decoder.decode("full_name")
        email = try decoder.decode("email")
        company = try decoder.decode("company")
        friends = try decoder.decode("friends")
        friendsLookup = try decoder.decode("friendsLookup")
    }
}

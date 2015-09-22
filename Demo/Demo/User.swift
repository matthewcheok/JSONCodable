//
//  User.swift
//  Demo
//
//  Created by Matthew Cheok on 18/7/15.
//  Copyright © 2015 matthewcheok. All rights reserved.
//

import Foundation
import JSONCodable

struct User {
    let id: Int
    let name: String
    var email: String?
    var company: Company?
    var friends: [User] = []
    var website: NSURL?
}

extension User: JSONCodable {
    init?(JSONDictionary: [String : AnyObject]) {
        do {
            id = try JSONDictionary.decode("id")
            name = try JSONDictionary.decode("full_name")
            email = try JSONDictionary.decode("email")
            company = try JSONDictionary.decode("company")
            friends = try JSONDictionary.decode("friends")
            website = try JSONDictionary.decode("website.url", transformer: JSONTransformers.StringToNSURL)
        }
        catch {
            print(error)
            return nil
        }
    }
    
    func toJSON() throws -> AnyObject {
        var result = [String: AnyObject]()
        try result.encode(id, key: "id")
        try result.encode(name, key: "full_name")
        try result.encode(email, key: "email")
        try result.encode(company, key: "company")
        try result.encode(friends, key: "friends")
        try result.encode(website, key: "website", transformer: JSONTransformers.StringToNSURL)
        return result
    }
}

//
//  RegularTests.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 13/10/15.
//
//

import XCTest

class RegularTests: XCTestCase {
    
    let encodedNestedArray = [
        "id": 99,
        "full_name": "Jen Jackson",
        "properties":[
            ["likes":5],
            ["likes":15],
            ["likes":25]
        ]
    ]
    
    let encodedValue = [
        "id": 24,
        "full_name": "John Appleseed",
        "email": "john@appleseed.com",
        "company": [
            "name": "Apple",
            "address": "1 Infinite Loop, Cupertino, CA"
        ],
        "friends": [
            ["id": 27, "full_name": "Bob Jefferson"],
            ["id": 29, "full_name": "Jen Jackson"]
        ],
        "friendsLookup": ["Bob Jefferson": ["id": 27, "full_name": "Bob Jefferson"]]
    ]
    let decodedValue = User(
        id: 24,
        likes:0,
        name: "John Appleseed",
        email: "john@appleseed.com",
        company: Company(name: "Apple", address: "1 Infinite Loop, Cupertino, CA"),
        friends: [
            User(id: 27, likes:0, name: "Bob Jefferson", email: nil, company: nil, friends: [], friendsLookup: nil),
            User(id: 29, likes:0, name: "Jen Jackson", email: nil, company: nil, friends: [], friendsLookup: nil)
        ],
        friendsLookup: ["Bob Jefferson":  User(id: 27, likes:0, name: "Bob Jefferson", email: nil, company: nil, friends: [], friendsLookup: nil)]
    )

    func testDecodingNestedArray() {
        guard let user = try? User(object: encodedNestedArray) else {
            XCTFail()
            return
        }
        XCTAssert(user.likes != nil, "\(encodedNestedArray))")
    }
    
    func testDecodingRegular() {
        guard let user = try? User(object: encodedValue) else {
            XCTFail()
            return
        }
        XCTAssertEqual(user, decodedValue)
    }
  
    func testEncodingRegular() {
        guard let json = try? decodedValue.toJSON() else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(json as! [String : NSObject], encodedValue)
    }
}

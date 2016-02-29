//
//  RegularTests.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 13/10/15.
//
//

import XCTest

class RegularTests: XCTestCase {
    
    let encodedValue = [
        "id": 24,
        "full_name": "John Appleseed",
        "email": "john@appleseed.com",
        "company": [
            "name": "Apple",
            "address": "1 Infinite Loop, Cupertino, CA"
        ],
        "friends": [
            ["id": 27, "full_name": "Bob Jefferson", "friends": []],
            ["id": 29, "full_name": "Jen Jackson", "friends": []]
        ],
        "friendsLookup": ["Bob Jefferson": ["id": 27, "full_name": "Bob Jefferson", "friends": []]]
    ]
    
    let encodedValueWithNulls = [
        "id": 24,
        "full_name": "John Appleseed",
        "email": "john@appleseed.com",
        "company": [
            "name": "Apple",
            "address": "1 Infinite Loop, Cupertino, CA"
        ],
        "friends": [
            ["id": 27, "full_name": "Bob Jefferson", "email": NSNull(), "company": NSNull(), "friends": [], "friendsLookup" : NSNull()],
            ["id": 29, "full_name": "Jen Jackson", "email": NSNull(), "company": NSNull(), "friends": [], "friendsLookup" : NSNull()]
        ],
        "friendsLookup": ["Bob Jefferson": ["id": 27, "full_name": "Bob Jefferson", "email": NSNull(), "company": NSNull(), "friends": [], "friendsLookup" : NSNull()]]
    ]
    let decodedValue = User(
        id: 24,
        name: "John Appleseed",
        email: "john@appleseed.com",
        company: Company(name: "Apple", address: "1 Infinite Loop, Cupertino, CA"),
        friends: [
            User(id: 27, name: "Bob Jefferson", email: nil, company: nil, friends: [], friendsLookup: nil),
            User(id: 29, name: "Jen Jackson", email: nil, company: nil, friends: [], friendsLookup: nil)
        ],
        friendsLookup: ["Bob Jefferson":  User(id: 27, name: "Bob Jefferson", email: nil, company: nil, friends: [], friendsLookup: nil)]
    )

    func testDecodingRegular() {
        guard let user = try? User(object: encodedValue) else {
            XCTFail()
            return
        }

        XCTAssertEqual(user, decodedValue)
    }
  
    func testEncodingRegular() {
        guard let json = try? decodedValue.toJSON([]) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(json as! [String : NSObject], encodedValue)
    }
    
    func testNullEncoding() {
        guard let json = try? decodedValue.toJSON([.EncodeNulls]) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(json as! [String : NSObject], encodedValueWithNulls)
    }
    
    func testNullDecoding() {
        guard let user = try? User(object: encodedValue) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(user, decodedValue)
    }
}

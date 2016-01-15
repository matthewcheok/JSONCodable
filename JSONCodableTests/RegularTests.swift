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
        ]
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
            ["id": 27, "full_name": "Bob Jefferson", "email": NSNull(), "company": NSNull(), "friends": []],
            ["id": 29, "full_name": "Jen Jackson", "email": NSNull(), "company": NSNull(), "friends": []]
        ]
    ]
    let decodedValue = User(
        id: 24,
        name: "John Appleseed",
        email: "john@appleseed.com",
        company: Company(name: "Apple", address: "1 Infinite Loop, Cupertino, CA"),
        friends: [
            User(id: 27, name: "Bob Jefferson", email: nil, company: nil, friends: []),
            User(id: 29, name: "Jen Jackson", email: nil, company: nil, friends: [])
        ])

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
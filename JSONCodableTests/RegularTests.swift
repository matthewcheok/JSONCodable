//
//  RegularTests.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 13/10/15.
//
//

import XCTest

class RegularTests: XCTestCase {
    
    let nestedCodableArray = ["areas" : [[10.0,10.5,12.5]],
                              "places":[["Tokyo","New York", "El Cerrito"]],
                              "business" : [[
                                [ "name": "Apple",
                                  "address": "1 Infinite Loop, Cupertino, CA"
                                ],
                                [ "name": "Propeller",
                                  "address": "1212 broadway, Oakland, CA"
                                ]
                                ]],
                              "assets": [[
                                [ "name": "image-name",
                                  "uri": "http://www.example.com/image.png"
                                ],
                                [ "name": "image2-name",
                                  "uri": "http://www.example.com/image2.png"
                                ]
                                ]]]
    
    let encodedNestedArray: [String : Any] = [
        "id": 99,
        "full_name": "Jen Jackson",
        "properties":[
            ["likes":5],
            ["likes":15],
            ["likes":25]
        ]
    ]
    
    let encodedValue: [String: Any] = [
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
    
    func testDecodeNestedCodableArray() {
        guard let nested = try? NestItem(object: nestedCodableArray) else {
            XCTFail()
            return
        }
        print("nested=",nested)
        let places = nested.places ?? [[]]
        let areas = nested.areas
        let business = nested.business
        let assets = nested.assets ?? [[]]
        XCTAssert(places == [["Tokyo","New York", "El Cerrito"]], "\(nestedCodableArray))")
        XCTAssert(areas == [[10.0,10.5,12.5]], "\(nestedCodableArray))")
        
        XCTAssert(business.map{ $0.map{ $0.name } } == [[try! Company(object:["name": "Apple",
                                                                              "address": "1 Infinite Loop, Cupertino, CA"]),
                                                         try! Company(object:[ "name": "Propeller",
                                                                               "address": "1212 broadway, Oakland, CA"])].map{ $0.name }],
                  "\(nestedCodableArray))")
        
        XCTAssert(assets.map{ $0.map{ $0.name } } == [[try! ImageAsset(object:[ "name": "image-name",
                                                                                "uri": "http://www.example.com/image.png"]),
                                                       try! ImageAsset(object: ["name": "image2-name",
                                                                                "uri": "http://www.example.com/image2.png"])].map{ $0.name }],
                  "\(nestedCodableArray))")
    }
    
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
        
        XCTAssertEqual(json as [String : Any], encodedValue)
    }
}

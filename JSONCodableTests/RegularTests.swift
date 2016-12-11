//
//  RegularTests.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 13/10/15.
//
//

import XCTest


class RegularTests: XCTestCase {

    let nestedCodableArray: [String: Any] = [
        "areas" : [[10.0,10.5,12.5]],
        "places": [["Tokyo","New York", "El Cerrito"]],
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
        "friends" : [],
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
            ["id": 27, "full_name": "Bob Jefferson", "friends" : [], ],
            ["id": 29, "full_name": "Jen Jackson", "friends" : [],
             ]
        ],
        "friendsLookup": ["Bob Jefferson": ["id": 27,  "friends" : [], "full_name": "Bob Jefferson"]]
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

    func testArrayOfUsers() {
        let userArray = [encodedValue, encodedValue]
        guard let users = try? [User](JSONArray: userArray) else {
            XCTFail()
            return
        }
        XCTAssertEqual(users[0], decodedValue)
        XCTAssertEqual(users[1], decodedValue)
    }

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

        XCTAssert(places as NSObject == [["Tokyo","New York", "El Cerrito"]] as NSObject, "\(nestedCodableArray))")
        XCTAssert(areas as NSObject == [[10.0,10.5,12.5]] as NSObject, "\(nestedCodableArray))")

        XCTAssert(business.map{ $0.map{ $0.name } } as NSObject == [[try! Company(object:["name": "Apple",
                                                                                          "address": "1 Infinite Loop, Cupertino, CA"]),
                                                                     try! Company(object:[ "name": "Propeller",
                                                                                           "address": "1212 broadway, Oakland, CA"])].map{ $0.name }] as NSObject,
                  "\(nestedCodableArray))")

        XCTAssert(assets.map{ $0.map{ $0.name } } as NSObject == [[try! ImageAsset(object:[ "name": "image-name",
                                                                                            "uri": "http://www.example.com/image.png"]),
                                                                   try! ImageAsset(object: ["name": "image2-name",
                                                                                            "uri": "http://www.example.com/image2.png"])].map{ $0.name }] as NSObject,
                  "\(nestedCodableArray))")
    }

    func testDecodingNestedArray() {
        do {
            let user = try User(object: encodedNestedArray)
            XCTAssert(user.likes != nil, "\(encodedNestedArray))")
        } catch {
            print("error returned as: \(error)")
            XCTFail()
        }
    }

    func testDecodingRegular() {
        do {
            let user = try User(object: encodedValue)
            XCTAssertEqual(user, decodedValue)
        } catch {
            print("error returned as: \(error)")
            XCTFail()
        }
    }

    func testEncodingRegular() {
        do {
            guard let json = try decodedValue.toJSON() as? NSDictionary else {
                XCTFail()
                return
            }
            XCTAssert(json == (encodedValue as NSDictionary))
        } catch {
            print("\(error.localizedDescription)")
            XCTFail()
        }
    }
}

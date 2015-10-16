//
//  EnumTests.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 13/10/15.
//
//

import XCTest

class EnumTests: XCTestCase {
    
    let encodedValue = ["name": "apple", "color": "Red"]
    let decodedValue = Fruit(name: "apple", color: FruitColor.Red)
    
    func testDecodingEnum() {
        guard let fruit = Fruit(JSONDictionary: encodedValue) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(fruit, decodedValue)
    }
    
    func testEncodingEnum() {
        guard let json = try? decodedValue.toJSON() else {
            XCTFail()
            return
        }
        
        guard let castedJSON = json as? [String: String] else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(castedJSON, encodedValue)
    }
    
}

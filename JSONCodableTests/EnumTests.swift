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
    
    let encodedValue2: [String: Any] = ["name": "Seaweed Pasta", "cuisines": ["Italian", "Japanese"]]
    let decodedValue2 = Food(name: "Seaweed Pasta", cuisines: [.Italian, .Japanese])
    
    func testDecodingEnum() {
        guard let fruit = try? Fruit(object: encodedValue) else {
            XCTFail()
            return 
        }
        
        XCTAssertEqual(fruit, decodedValue)
        
        guard let food = try? Food(object: encodedValue2) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(food, decodedValue2)
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
        
        guard let json2 = try? decodedValue2.toJSON() else {
            XCTFail()
            return
        }
        
        print(json2, encodedValue2)
    }
    
}

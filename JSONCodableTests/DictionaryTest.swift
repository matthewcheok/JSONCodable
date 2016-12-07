//
//  Copyright (C) 2016 Lukas Schmidt.
//
//  Permission is hereby granted, free of charge, to any person obtaining a 
//  copy of this software and associated documentation files (the "Software"), 
//  to deal in the Software without restriction, including without limitation 
//  the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//  and/or sell copies of the Software, and to permit persons to whom the 
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in 
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
//  DEALINGS IN THE SOFTWARE.
//
//
//  DictionaryTest.swift
//  JSONCodable
//
//  Created by Lukas Schmidt on 17.11.16.
//

import XCTest
@testable import JSONCodable

struct Value {
    let id: Int
}

extension Value: JSONDecodable {
    init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        id = try decoder.decode("id")
    }
}

class DictionaryTest: XCTestCase {
    
    func testParse_withInt() {
        //Given
        let json = ["dict": ["id": 1]]
        let decoder = JSONDecoder(object: json)
        
        //When
        let result: [String: Int] = try! decoder.decode("dict")
        
        //Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result["id"], 1)
    }
    
    func testParse_withString() {
        //Given
        let json = ["dict": ["id": "1"]]
        let decoder = JSONDecoder(object: json)
        
        //When
        let result: [String: String] = try! decoder.decode("dict")
        
        //Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result["id"], "1")
    }
    
    func testParse_withDouble() {
        //Given
        let json = ["dict": ["id": 1.00]]
        let decoder = JSONDecoder(object: json)
        
        //When
        let result: [String: Double] = try! decoder.decode("dict")
        
        //Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result["id"], 1.00)
    }
    
    func testParse_withBool() {
        //Given
        let json = ["dict": ["id": true]]
        let decoder = JSONDecoder(object: json)
        
        //When
        let result: [String: Bool] = try! decoder.decode("dict")
        
        //Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result["id"], true)
    }

    func testParse_withBool_optional() {
        //Given
        let json = ["dict": ["id": true]]
        let decoder = JSONDecoder(object: json)
        
        //When
        let result: [String: Bool]? = try! decoder.decode("dict")
        
        //Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?["id"], true)
    }
    
    func testParse_withInt_optional() {
        //Given
        let json = ["dict": ["id": 1]]
        let decoder = JSONDecoder(object: json)
        
        //When
        let result: [String: Int]? = try! decoder.decode("dict")
        
        //Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?["id"], 1)
    }
    
    func testParse_withString_optional() {
        //Given
        let json = ["dict": ["id": "1"]]
        let decoder = JSONDecoder(object: json)
        
        //When
        let result: [String: String]? = try! decoder.decode("dict")
        
        //Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?["id"], "1")
    }
    
    func testParse_withDouble_optional() {
        //Given
        let json = ["dict": ["id": 1.00]]
        let decoder = JSONDecoder(object: json)
        
        //When
        let result: [String: Double]? = try! decoder.decode("dict")
        
        //Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?["id"], 1.00)
    }
    
    func testParse_object() {
        //Given
        let json = ["dict": ["dict": ["id": 1]]]
        let decoder = JSONDecoder(object: json)
        
        //When
        let result: [String: Value] = try! decoder.decode("dict")
        
        //Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result["dict"]?.id, 1)
    }
    
    func testParse_object_optional() {
        //Given
        let json = ["dict": ["dict": ["id": 1]]]
        let decoder = JSONDecoder(object: json)
        
        //When
        let result: [String: Value]? = try! decoder.decode("dict")
        
        //Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?["dict"]?.id, 1)
    }
}

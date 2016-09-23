//
//  JSONCodableTests.swift
//  JSONCodableTests
//
//  Created by Tobias Conradi on 14.10.15.
//  Copyright © 2015 matthewcheok. All rights reserved.
//

import XCTest
@testable import JSONCodable

struct NotEncodable {
}

class HelperTests: XCTestCase {
    
    func testArrayElementsAreEncodable() {
        let intArray:[Int] = [1,2,3]
        XCTAssert(intArray.elementsAreJSONEncodable(), "Array of type [Int] should be encodable")
        
        let encodableArray:[JSONEncodable] = [1,2,3]
        XCTAssert(encodableArray.elementsAreJSONEncodable(), "Array of type [JSONEncodable] should be encodable")
        
        let notEncodableArray:[NotEncodable] = [NotEncodable()]
        XCTAssert(!notEncodableArray.elementsAreJSONEncodable(), "Array of type [NotEncodable] should not be encodable")
        
        let _ = try? JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(intArray, key: "intArray")
            try encoder.encode(encodableArray, key: "encodableArray")
        })
    }
    
    func testDictionaryIsEncodable() {
        let intDict:[String:Int] = ["a":1,"b":2,"c":3]
        XCTAssert(intDict.valuesAreJSONEncodable(), "Dictionary of type [String:Int] should be encodable")
        
        let encodableDict:[String:JSONEncodable] = ["a":1,"b":2,"c":3]
        XCTAssert(encodableDict.valuesAreJSONEncodable(), "Dictionary of type [String:JSONEncodable] should be encodable")
        
        let notEncodableDict:[String:NotEncodable] = ["a":NotEncodable()]
        XCTAssert(!notEncodableDict.valuesAreJSONEncodable(), "Dictionary of type [String:NotEncodable] should not be encodable")
        
        let _ = try? JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(intDict, key: "intArray")
            try encoder.encode(encodableDict, key: "encodableArray")
        })
    }
    
}

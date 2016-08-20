//
//  UtilityTests.swift
//  JSONCodable
//
//  Created by FoxRichard on 3/9/16.
//
//

import XCTest
@testable import JSONCodable

class UtilityTests: XCTestCase {
    func testArrayIndexDecoding() {
        let jsonObj = ["test":"test"]
        let decoder = JSONDecoder(object: jsonObj)
        XCTAssert(decoder.parseArrayIndex("[0]") ==  0)
        XCTAssert(decoder.parseArrayIndex("[1]") ==  1)
        XCTAssert(decoder.parseArrayIndex("[10]") == 10)
        XCTAssert(decoder.parseArrayIndex("[202]") == 202)
        XCTAssert(decoder.parseArrayIndex("[1111111]") == 1111111)
        XCTAssert(decoder.parseArrayIndex("[zero]") == nil)
        XCTAssert(decoder.parseArrayIndex("[1A]") == nil)
        XCTAssert(decoder.parseArrayIndex("[^]") ==  nil)
        XCTAssert(decoder.parseArrayIndex("HAHA") == nil)
        XCTAssert(decoder.parseArrayIndex("[-1]") == -1)
    }
}

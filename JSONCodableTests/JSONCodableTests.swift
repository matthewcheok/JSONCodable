//
//  JSONCodableTests.swift
//  JSONCodableTests
//
//  Created by Tobias Conradi on 14.10.15.
//  Copyright © 2015 matthewcheok. All rights reserved.
//

import XCTest
@testable import JSONCodable

class JSONCodableTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	struct NotEncodable {
	}

    func testArrayElementsAreEncodable() {
		let intArray:[Int] = [1,2,3]
		XCTAssert(intArray.elementsAreJSONEncodable(), "Array of type [Int] should be encodable")

		let encodableArray:[JSONEncodable] = [1,2,3]
		XCTAssert(encodableArray.elementsAreJSONEncodable(), "Array of type [JSONEncodable] should be encodable")

		let notEncodableArray:[NotEncodable] = [NotEncodable()]
		XCTAssert(!notEncodableArray.elementsAreJSONEncodable(), "Array of type [NotEncodable] should not be encodable")
	}

	func testDictionaryIsEncodable() {
		let intDict:[String:Int] = ["a":1,"b":2,"c":3]
		XCTAssert(intDict.dictionaryIsJSONEncodable(), "Dictionary of type [String:Int] should be encodable")

		let encodableDict:[String:JSONEncodable] = ["a":1,"b":2,"c":3]
		XCTAssert(encodableDict.dictionaryIsJSONEncodable(), "Dictionary of type [String:JSONEncodable] should be encodable")

		let notEncodableDict:[String:NotEncodable] = ["a":NotEncodable()]
		XCTAssert(!notEncodableDict.dictionaryIsJSONEncodable(), "Dictionary of type [String:NotEncodable] should not be encodable")

	}


    
}

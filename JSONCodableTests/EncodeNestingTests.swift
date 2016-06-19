//
//  EncodeNestingTests.swift
//  JSONCodable
//
//  Created by Richard Fox on 6/19/16.
//
//

import XCTest
import JSONCodable

class EncodeNestingTests: XCTestCase {

    let propertyItemArray: JSONObject = [
        "class": "propertyType",
        "rel": "propertyType",
        "properties" :
        [ "name" : "person",
          "location" : [ "coord" : [
                "lat" : 37.790770,
                "long"  : -122.402015
        ]]]]

    func testEncodeNestedPropertyItem() {
        guard let pItem = try? PropertyItem(object: propertyItemArray),
            json = try? pItem.toJSON(),
            json1 = json as? JSONObject else {
            XCTFail()
            return
        }
        print(String(json1))
        print("\n\n")
        print(String(propertyItemArray))
        XCTAssert(String(json1) == String(propertyItemArray), "failed to convert to \(propertyItemArray)")
    }
}

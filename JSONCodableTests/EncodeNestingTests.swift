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
        "properties":
            [ "name": "person",
              "location": [ "coord": [
                "lat": 37.790770,
                "long": -122.402015
                ]]]]
    
    func testEncodeNestedPropertyItem() {
        guard let pItem = try? PropertyItem(object: propertyItemArray),
            let json = try? pItem.toJSON(),
            let json1 = json as? JSONObject else {
                XCTFail()
                return
        }
        XCTAssert(String(describing:json1) == String(describing:propertyItemArray), "failed to convert to \(propertyItemArray)")
    }
}

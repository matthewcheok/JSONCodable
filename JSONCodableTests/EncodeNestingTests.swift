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

        XCTAssertEqual(json1["class"] as! String, propertyItemArray["class"] as! String)
        XCTAssertEqual(json1["class"] as! String, propertyItemArray["class"] as! String)

        let properties = propertyItemArray["properties"] as! [String: Any]
        let properties1 = json1["properties"] as! [String: Any]
        XCTAssertEqual(properties1["name"] as! String, properties["name"] as! String)

        let location = properties["location"] as! [String: Any]
        let location1 = properties1["location"] as! [String: Any]

        let coord = location["coord"] as! [String: Any]
        let coord1 = location1["coord"] as! [String: Any]
        XCTAssertEqual(coord["lat"] as! Double, coord1["lat"] as! Double)
        XCTAssertEqual(coord["long"] as! Double, coord1["long"] as! Double)
    }
}

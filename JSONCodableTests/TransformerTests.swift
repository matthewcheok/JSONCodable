//
//  TransformerTests.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 13/10/15.
//
//

import XCTest

class TransformerTests: XCTestCase {
    
    let encodedValue = [
        "name": "image-name",
        "uri": "http://www.example.com/image.png"
    ]
    let decodedValue = ImageAsset(
        name: "image-name",
        uri: NSURL(string: "http://www.example.com/image.png")
    )
    
    func testDecodingTransformer() {
        guard let asset = try? ImageAsset(object: encodedValue) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(asset, decodedValue)
    }
    
    func testEncodingTransformer() {
        guard let json = try? decodedValue.toJSON() else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(json as! [String : NSObject], encodedValue)
    }
    
}
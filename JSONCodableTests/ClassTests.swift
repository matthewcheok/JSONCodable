//
//  ClassTests.swift
//  JSONCodable
//
//  Created by FoxRichard on 12/18/16.
//
//

import XCTest
@testable import JSONCodable

class ClassTests: XCTestCase {

    let nameCountJson: [String: Any] = [
        "name" : "rich",
        "count" : 5
    ]

    func testNameCount() {
        do {
            let person = try NameCount.jsonConstruct(object: nameCountJson)
            XCTAssertEqual(nameCountJson["count"] as? Int, person.count)
            XCTAssertEqual(nameCountJson["name"] as? String, person.name)
        } catch {
            XCTFail()
            return
        }
    }
}

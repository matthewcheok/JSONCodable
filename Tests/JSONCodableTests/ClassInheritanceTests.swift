//
//  ClassInheritanceTests.swift
//  JSONCodable
//
//  Created by Andy Steinmann on 12/6/16.
//
//

import Foundation
import XCTest
import JSONCodable

class ClassInheritanceTests: XCTestCase {
    func testJSONEncodableIncludesPropertiesFromSuperClasses() {
        // Arrange
        let child = Child()
        child.parentProperty1 = "NewTestValue"
        
        do {
            //Act
            let json = try child.toJSON() as? JSONObject
            let newChild = try Child(object: json!)
            
            // Assert
            XCTAssertEqual(child.parentProperty1, newChild.parentProperty1)
        } catch {
            XCTFail()
        }

    }
}

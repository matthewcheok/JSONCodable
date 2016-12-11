//
//  MirrorTests.swift
//  JSONCodable
//
//  Created by Andy Steinmann on 7/14/16.
//
//

import XCTest

class MirrorTests: XCTestCase {
    func testMirrorGetAllPropertiesWorksWithNoInheritance() {
        // Arrange
        let expectedPropertyCount = 2
        let parent = Parent()
        let mirror = Mirror(reflecting: parent)
        
        // Act
        let actualPropertyCount = mirror.getAllProperties().count
        
        // Assert
        XCTAssertEqual(expectedPropertyCount, actualPropertyCount)
        
    }
    
    func testMirrorGetAllPropertiesWorksWithOneLevelOfInheritance() {
        // Arrange
        let expectedPropertyCount = 4
        let child = Child()
        let mirror = Mirror(reflecting: child)
        
        // Act
        let actualPropertyCount = mirror.getAllProperties().count
        
        // Assert
        XCTAssertEqual(expectedPropertyCount, actualPropertyCount)
        
    }
    
    func testMirrorGetAllPropertiesWorksWithTwoLevelsOfInheritance() {
        // Arrange
        let expectedPropertyCount = 6
        let grandChild = Grandchild()
        let mirror = Mirror(reflecting: grandChild)
        
        // Act
        let actualPropertyCount = mirror.getAllProperties().count
        
        // Assert
        XCTAssertEqual(expectedPropertyCount, actualPropertyCount)
        
    }
    
    func testMirrorGetAllPropertiesWorksWithAStruct() {
        // Arrange
        let expectedPropertyCount = 2
        let fruit = Fruit(name: "Test Fruit", color: .Red)
        let mirror = Mirror(reflecting: fruit)
        
        // Act
        let actualPropertyCount = mirror.getAllProperties().count
        
        // Assert
        XCTAssertEqual(expectedPropertyCount, actualPropertyCount)
        
    }

}

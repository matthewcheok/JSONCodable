//
//  ClassInheritance.swift
//  JSONCodable
//
//  Created by Andy Steinmann on 7/14/16.
//
//

import Foundation
import JSONCodable

class Parent : JSONCodable
{
    var parentProperty1:String = "parent1"
    var parentProperty2:String = "parent2"
    
    init(){
    }
    required init(object map: JSONObject) throws {
        let decoder = JSONDecoder(object: map)
        parentProperty1 = try decoder.decode("parentProperty1")
        parentProperty2 = try decoder.decode("parentProperty2")
    }
    
}

class Child : Parent
{
    var childProperty1:String = "child1"
    var childProperty2:String = "child2"
    
    override init(){
        super.init()
    }
    
    required init(object map: JSONObject) throws {
        let decoder = JSONDecoder(object: map)
        childProperty1 = try decoder.decode("childProperty1")
        childProperty2 = try decoder.decode("childProperty2")
        try super.init(object: map)
    }
}

class Grandchild : Child
{
    var grandChildProperty1:String = "grandChild1"
    var grandChildProperty2:String = "grandChild2"
    
    override init(){
        super.init()
    }
    required init(object map: JSONObject) throws {
        let decoder = JSONDecoder(object: map)
        grandChildProperty1 = try decoder.decode("grandChildProperty1")
        grandChildProperty2 = try decoder.decode("grandChildProperty2")
        try super.init(object: map)
    }
}

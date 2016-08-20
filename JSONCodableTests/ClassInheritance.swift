//
//  ClassInheritance.swift
//  JSONCodable
//
//  Created by Andy Steinmann on 7/14/16.
//
//

import Foundation

class Parent
{
    var parentProperty1:String = "parent1"
    var parentProperty2:String = "parent2"
}

class Child : Parent
{
    var childProperty1:String = "child1"
    var childProperty2:String = "child2"
}

class Grandchild : Child
{
    var grandChildProperty1:String = "grandChild1"
    var grandChildProperty2:String = "grandChild2"
}

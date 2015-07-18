//
//  Company.swift
//  Demo
//
//  Created by Matthew Cheok on 18/7/15.
//  Copyright © 2015 matthewcheok. All rights reserved.
//

import Foundation
import JSONCodable

struct Company {
    let name: String
    var address: String?
}

extension Company: JSONCodable {
    init?(JSONDictionary: [String : AnyObject]) {
        do {
            name = try JSONDictionary.decode("name")
            address = try JSONDictionary.decode("address")
        }
        catch {
            print(error)            
            return nil
        }
    }
    
    func toJSON() throws -> AnyObject {
        var result = [String: AnyObject]()
        try result.encode(name, key: "name")
        try result.encode(address, key: "address")
        return result
    }
}
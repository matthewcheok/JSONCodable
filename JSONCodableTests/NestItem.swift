//
//  NestItem.swift
//  JSONCodable
//
//  Created by FoxRichard on 5/9/16.
//
//

import Foundation
import JSONCodable

struct NestItem {
    let areas: [[Double]]
    var places: [[String]]?
}

extension NestItem: JSONDecodable {
    init(object: JSONObject) throws {
        do {
            let decoder = JSONDecoder(object: object)
            areas = try decoder.decode("areas")
            places = try decoder.decode("places")
        }catch{
            fatalError("\(error)")
        }
    }

}


//
//  NestItem.swift
//  JSONCodable
//
//  Created by FoxRichard on 5/9/16.
//
//

import JSONCodable

struct NestItem {
    let areas: [[Double]]
    var places: [[String]]?
    var business: [[Company]]
    var assets: [[ImageAsset]]?
}

extension NestItem: JSONDecodable {
    init(object: JSONObject) throws {
        do {
            let decoder = JSONDecoder(object: object)
            areas = try decoder.decode("areas")
            places = try decoder.decode("places")
            business = try decoder.decode("business")
            assets = try decoder.decode("assets")
        }catch{
            fatalError("\(error)")
        }
    }
}

//
//  PropertyCompany.swift
//  JSONCodable
//
//  Created by FoxRichard on 11/5/16.
//
//

import JSONCodable

struct PropertyCompany {
    let properties: [PropertyItem]
    let companies: [Company]
}

extension PropertyCompany: JSONEncodable {}

extension PropertyCompany: JSONDecodable {
    init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        properties = try decoder.decode("companies_properties", filter: true)
        companies = try decoder.decode("companies_properties", filter: true)
    }
}

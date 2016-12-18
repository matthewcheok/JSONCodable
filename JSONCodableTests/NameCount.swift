//
//  NameCount.swift
//  JSONCodable
//
//  Created by FoxRichard on 12/18/16.
//
//

import JSONCodable

class NameCount {
    let name: String
    let count: Int
    init(name: String, count: Int) {
        self.name = name
        self.count = count
    }
}

extension NameCount: JSONObjDecodable {

    static func jsonConstruct(object: JSONObject) throws -> Self {
        let decoder = JSONDecoder(object: object)

        let result = NameCount(name: try decoder.decode("name"),
                               count: try decoder.decode("count"))

        return DecodableCastAs(object: result)
    }
}

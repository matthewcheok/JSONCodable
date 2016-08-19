//
//  Messages.swift
//  JSONCodable
//
//  Created by Richard Fox on 6/25/16.
//
//

import JSONCodable

struct Messages {
    let id: [JSONObject]
}

extension Messages: JSONDecodable {
    init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        id = try decoder.decode("", transformer: JSONTransformers.JSONObjectArray)
    }
}

struct MessageComplex {
    let id: JSONObject
    let nestedId: Int
}

extension MessageComplex: JSONDecodable {
    init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        id = try decoder.decode("[0]", transformer: JSONTransformers.JSONObjectType)
        nestedId = try decoder.decode("[1].ID")
    }
}

//Transforms for returning JSONObject & [JSONObject]

extension JSONTransformers {
    
    static let JSONObjectType = JSONTransformer<JSONObject,JSONObject>(
        decoding: { $0 },
        encoding: { $0 })
    
    static let JSONObjectArray = JSONTransformer<[JSONObject],[JSONObject]>(
        decoding: { $0 },
        encoding: { $0 })
}

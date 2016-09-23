//
//  ImageAsset.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 14/10/15.
//
//

import JSONCodable

struct ImageAsset: Equatable {
  let name: String
  var uri: URL?
}

func ==(lhs: ImageAsset, rhs: ImageAsset) -> Bool {
  return lhs.name == rhs.name && lhs.uri == rhs.uri
}

extension ImageAsset: JSONEncodable {
  func toJSON() throws -> Any {
    return try JSONEncoder.create{ (encoder) -> Void in
      try encoder.encode(name, key: "name")
      try encoder.encode(uri, key: "uri", transformer: JSONTransformers.StringToURL)
    }
  }
}

extension ImageAsset: JSONDecodable {
  init(object: JSONObject) throws {
    let decoder = JSONDecoder(object: object)
    name = try decoder.decode("name")
    uri = try decoder.decode("uri", transformer: JSONTransformers.StringToURL)
  }
}

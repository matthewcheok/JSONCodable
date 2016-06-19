//
//  JSONTransformer.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 17/7/15.
//  Copyright © 2015 matthewcheok. All rights reserved.
//

// Converting between types

public struct JSONTransformer<EncodedType, DecodedType>: CustomStringConvertible {
  let decoding: ((EncodedType) -> DecodedType?)
  let encoding: ((DecodedType) -> EncodedType?)
  
  // needs public accessor
  public init(decoding: ((EncodedType) -> DecodedType?), encoding: ((DecodedType) -> EncodedType?)) {
    self.decoding = decoding
    self.encoding = encoding
  }
  
  public var description: String {
    return "JSONTransformer \(EncodedType.self) <-> \(DecodedType.self)"
  }
}

import Foundation
private let dateTimeFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
  formatter.timeZone = TimeZone(forSecondsFromGMT: 0)
  formatter.locale = Locale(localeIdentifier: "en_US_POSIX")
  return formatter
}()

public struct JSONTransformers {
  public static let StringToNSURL = JSONTransformer<String, URL>(
    decoding: {URL(string: $0)},
    encoding: {$0.absoluteString})
  
  public static let StringToNSDate = JSONTransformer<String, Date>(
    decoding: {dateTimeFormatter.date(from: $0)},
    encoding: {dateTimeFormatter.string(from: $0)})
}

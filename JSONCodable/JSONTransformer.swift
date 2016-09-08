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
    public init(decoding: @escaping ((EncodedType) -> DecodedType?), encoding: @escaping ((DecodedType) -> EncodedType?)) {
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
    formatter.timeZone = TimeZone(secondsFromGMT:0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()

public struct JSONTransformers {
    public static let StringToURL = JSONTransformer<String, URL>(
        decoding: {URL(string: $0)},
        encoding: {$0.absoluteString})
    
    public static let StringToDate = JSONTransformer<String, Date>(
        decoding: {dateTimeFormatter.date(from: $0)},
        encoding: {dateTimeFormatter.string(from: $0)})
}

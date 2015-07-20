//
//  JSONTransformer.swift
//  JSONCodable
//
//  Created by Matthew Cheok on 17/7/15.
//  Copyright © 2015 matthewcheok. All rights reserved.
//

// Converting between types

public struct JSONTransformer<EncodedType, DecodedType>: CustomStringConvertible {
    let decoding: (EncodedType -> DecodedType?)
    let encoding: (DecodedType -> EncodedType?)
    
    // needs public accessor 
    public init(decoding: (EncodedType -> DecodedType?), encoding: (DecodedType -> EncodedType?)) {
        self.decoding = decoding
        self.encoding = encoding
    }
    
    public var description: String {
        return "JSONTransformer \(EncodedType.self) <-> \(DecodedType.self)"
    }
}

import Foundation
private let dateTimeFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    return formatter
}()

public struct JSONTransformers {
    public static let StringToNSURL = JSONTransformer<String, NSURL>(
        decoding: {NSURL(string: $0)},
        encoding: {$0.absoluteString})

    public static let StringToNSDate = JSONTransformer<String, NSDate>(
        decoding: {dateTimeFormatter.dateFromString($0)},
        encoding: {dateTimeFormatter.stringFromDate($0)})

}

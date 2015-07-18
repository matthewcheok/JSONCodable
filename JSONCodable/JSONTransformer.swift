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
public struct JSONTransformers {
    public static let StringToNSURL = JSONTransformer<String, NSURL>(
        decoding: {NSURL(string: $0)},
        encoding: {$0.absoluteString})
}

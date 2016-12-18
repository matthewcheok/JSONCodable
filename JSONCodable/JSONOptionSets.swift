//
//  JSONOptionSets.swift
//  JSONCodable
//
//  Created by FoxRichard on 12/11/16.
//
//

import Foundation

public struct JSONDecodingOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static  let allowDotsInKeys = JSONDecodingOptions(rawValue: 1)
    public static let allowEmptyObjects = JSONDecodingOptions(rawValue: 2)
    public static let filterInvalidObjects = JSONDecodingOptions(rawValue: 3)
}

public struct JSONEncodingOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let allowDotsInKeys = JSONDecodingOptions(rawValue: 1)
    public static let allowEmptyObjects = JSONDecodingOptions(rawValue: 2)
}


//
//  DictionaryTests.swift
//  JSONCodable
//
//  Created by FoxRichard on 11/5/16.
//
//

import XCTest

class ArrayTests: XCTestCase {

    let mixedArrayJSON = [
        [
        "class": "propertyType",
        "rel": "propertyType",
        "properties":
            [ "name": "John",
              "location": [ "coord": [
                "lat": 37.790770,
                "long": -122.402015
                ]]]],
        ["name": "CompanyInc",
         "address": "1414 place st Los Angeles, CA"],
        [
        "class": "propertyType",
        "rel": "propertyType",
        "properties":
            [ "name": "Joe",
            "location": [ "coord": [
            "lat": 38.790770,
            "long": -121.402015
            ]]]],   
    ["name": "SoftwareInc",
    "address": "1313 place st Oakland, CA"]
    ]

    let companiesJSON: [[String: String]] = [
        ["name": "CompanyInc",
         "address": "1414 place st Los Angeles, CA"],
        ["name": "SoftwareInc",
         "address": "1313 place st Oakland, CA"]
        ]

    func testMixedItemsInArray() {
        do {
            let companies = try [Company](JSONArray: mixedArrayJSON, filtered: true)
            guard let companyValues = try? companies.toJSON(),
                let companiesEncoded:[[String: String]] = (companyValues as? [[String: String]]) else {
                XCTFail()
                return
            }
            XCTAssert(companiesEncoded.count == 2, "encoding invalid")
            XCTAssert(companiesJSON.count == 2, "companies mapping invalid")
            XCTAssert(companiesEncoded[0] == companiesJSON[0], "companies values incorrect")
            XCTAssert(companiesEncoded[1] == companiesJSON[1], "companies values incorrect")
            print(companies)
        } catch {
            print("\(error)")
            XCTFail()
        }
    }

    func testMixedItemsInArrayNotFiltered() {
        do {
            let _ = try [Company](JSONArray: mixedArrayJSON, filtered: false)
            XCTFail()
        } catch {
            print("mapping should fail if not filtered")
        }
    }

    func testCompanyProperties() {
        let companyPropertiesJSON = ["companies_properties" : mixedArrayJSON]
        do {
            let companiesAndProperties = try PropertyCompany(object: companyPropertiesJSON)
            print(companiesAndProperties)
        } catch {
            print(error)
            XCTFail()
        }

        
    }
}

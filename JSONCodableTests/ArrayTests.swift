//
//  DictionaryTests.swift
//  JSONCodable
//
//  Created by FoxRichard on 11/5/16.
//
//

import XCTest
import JSONCodable

class ArrayTests: XCTestCase {

    let mixedArrayJSON = [
        [
        "idList": [1,2,3],
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
            "idList": [1,2,3],
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
    
    func testParseArray_WithInt() {
        //Given
        
        let integers = ["array": [1, 2, 3]]
        let parser = JSONDecoder(object: integers)
        
        //When
        let parsed: Array<Int>? = try? parser.decode("array")
        
        //Then
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.count, 3)
    }

    func testMixedItemsInArray() {
        do {
            let companies = try [Company](JSONArray: mixedArrayJSON, filtered: true)
            guard let companyValues = try? companies.toJSON(),
                let companiesEncoded:[[String: String]] = (companyValues as? [[String: String]]) else {
                XCTFail()
                return
            }
            XCTAssertEqual(companiesEncoded.count, 2, "encoding invalid")
            XCTAssertEqual(companiesJSON.count, 2, "companies mapping invalid")
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

//    func testCompanyProperties() {
//        let companyPropertiesJSON = ["companies_properties" : mixedArrayJSON]
//        do {
//            let companiesAndProperties = try PropertyCompany(object: companyPropertiesJSON)
//            print(companiesAndProperties)
//        } catch {
//            print(error)
//            XCTFail()
//        }
//        
//    }
    
    
    func parse<T: JSONDecodable>(json: Dictionary<String, Any>, expectedResult: Array<T>, file: StaticString = #file, line: UInt = #line) where T: Equatable {
        //Given
        let decoder = JSONDecoder(object: json)
        
        //When
        do {
            let result: [T] = try decoder.decode("values")
            XCTAssertEqual(result.count, 3)
            XCTAssertEqual(result[0], expectedResult[0], file: file, line: line)
            XCTAssertEqual(result[1], expectedResult[1], file: file, line: line)
            XCTAssertEqual(result[2], expectedResult[2], file: file, line: line)
            let optionalResult: [T]? = try decoder.decode("values")
            XCTAssertEqual(result.count, 3)
            XCTAssertEqual(result[0], optionalResult?[0], file: file, line: line)
            XCTAssertEqual(result[1], optionalResult?[1], file: file, line: line)
            XCTAssertEqual(result[2], optionalResult?[2], file: file, line: line)
        } catch let err as JSONDecodableError {
            XCTFail(err.description, file: file, line: line)
        } catch {
            XCTFail("Failed with unspecified error")
        }
    }
    
    func parse<T: JSONDecodable>(expectedResult: Array<T>, file: StaticString = #file, line: UInt = #line) where T: Equatable {
        //Given
        let json = ["values": expectedResult]
        
        //When
        parse(json: json, expectedResult: expectedResult, file: file, line: line)
    }
    
    func testParse_withInt() {
        //Given
        let values = [0, 1, 2]
        
        //When
        parse(expectedResult: values)
    }
    
    func testParse_withInt_empty() {
        //Given
        let json = ["values": []]
        let decoder = JSONDecoder(object: json)
        
        //When
        do {
            let result: [Int] = try decoder.decode("values")
            XCTAssertEqual(result.count, 0)
            
        } catch let err {
            XCTFail()
        }
    }
    
    func testParse_withString() {
        //Given
        let values = ["0", "1", "2"]
        
        //When
        parse(expectedResult: values)
    }
    
    func testParse_withDouble() {
        //Given
        let values = [0.0, 0.1, 0.2]
        
        //When
        parse(expectedResult: values)
    }
    
    func testParse_withBool() {
        //Given
        let values = [true, false, true]
        
        //When
        parse(expectedResult: values)
    }
    
    func testParse_withEnum() {
        //Given
        let result = ["Red", "Blue", "Red"]
        let expectedResult = [FruitColor.Red, FruitColor.Blue, FruitColor.Red]
        
        let json = ["values": result]
        let decoder = JSONDecoder(object: json)
        
        //When
        do {
            let result: [FruitColor] = try decoder.decode("values")
            XCTAssertEqual(result.count, 3)
            XCTAssertEqual(result[0], expectedResult[0])
            XCTAssertEqual(result[1], expectedResult[1])
            XCTAssertEqual(result[2], expectedResult[2])
            let optionalResult: [FruitColor]? = try decoder.decode("values")
            XCTAssertEqual(result.count, 3)
            XCTAssertEqual(result[0], optionalResult?[0])
            XCTAssertEqual(result[1], optionalResult?[1])
            XCTAssertEqual(result[2], optionalResult?[2])
        } catch let err as JSONDecodableError {
            XCTFail(err.description)
        } catch {
            XCTFail("Failed with unspecified error")
        }
    }
    
    func testParse_withObject() {
        let json = ["values": [["name": "1", "address": "2"], ["name": "2"]]]
        
        let decoder = JSONDecoder(object: json)
        do {
            let result: [Company] = try decoder.decode("values")
            XCTAssertEqual(result[0], Company(name: "1", address: "2"))
            XCTAssertEqual(result[1], Company(name: "2", address: nil))
            
            let resultOptional: [Company]? = try decoder.decode("values")
            XCTAssertEqual(resultOptional?[0], Company(name: "1", address: "2"))
            XCTAssertEqual(resultOptional?[1], Company(name: "2", address: nil))
            
        } catch let err as JSONDecodableError {
            XCTFail(err.description)
        } catch {
            XCTFail("Failed with unspecified error")
        }
    }
}

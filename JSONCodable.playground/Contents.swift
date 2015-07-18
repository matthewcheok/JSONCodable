/*:
# JSONCodable

Hassle-free JSON encoding and decoding in Swift

`JSONCodable` is made of two seperate protocols `JSONEncodable` and `JSONDecodable`.

`JSONEncodable` generates `Dictionary`s (compatible with `NSJSONSerialization`) and `String`s from your types while `JSONDecodable` creates structs (or classes) from compatible `Dictionary`s (from an incoming network request for instance)
*/
import JSONCodable
/*:
Here's some data models we'll use as an example:
*/

struct User {
    let id: Int
    let name: String
    var email: String?
    var company: Company?
    var friends: [User] = []
}

struct Company {
    let name: String
    var address: String?
}

/*:
## JSONEncodable
We'll add conformance to `JSONEncodable`. You may also add conformance to `JSONCodable`.
*/

extension User: JSONEncodable {
    func JSONEncode() throws -> AnyObject {
        var result = [String: AnyObject]()
        try result.encode(id, key: "id")
        try result.encode(name, key: "full_name")
        try result.encode(email, key: "email")
        try result.encode(company, key: "company")
        try result.encode(friends, key: "friends")
        return result
    }
}

extension Company: JSONEncodable {}

/*:
The default implementation of `func JSONEncode()` inspects the properties of your type using reflection. (Like in `Company`.) If you need a different mapping, you can provide your own implementation (like in `User`.)
*/

/*:
## JSONDecodable
We'll add conformance to `JSONDecodable`. You may also add conformance to `JSONCodable`.
*/

extension User: JSONDecodable {
    init?(JSONDictionary: [String:AnyObject]) {
        do {
            id = try JSONDictionary.decode("id")
            name = try JSONDictionary.decode("full_name")
            email = try JSONDictionary.decode("email")
            company = try JSONDictionary.decode("company")
            friends = try JSONDictionary.decode("friends")
        }
        catch {
            return nil
        }
    }
}

extension Company: JSONDecodable {
    init?(JSONDictionary: [String:AnyObject]) {
        do {
            name = try JSONDictionary.decode("name")
            address = try JSONDictionary.decode("address")
        }
        catch {
            return nil
        }
    }
}

/*:
Simply provide the implementations for `init?(JSONDictionary: [String:AnyObject])`. As before, you can use this to configure the mapping between keys in the `Dictionary` to properties in your structs and classes.
*/

/*:
## Test Drive

You can open the console and see the output using `CMD + SHIFT + Y` or ⇧⌘Y.
Let's work with an incoming JSON Dictionary:
*/

let JSON = [
    "id": 24,
    "full_name": "John Appleseed",
    "email": "john@appleseed.com",
    "company": [
        "name": "Apple",
        "address": "1 Infinite Loop, Cupertino, CA"
    ],
    "friends": [
        ["id": 27, "full_name": "Bob Jefferson"],
        ["id": 29, "full_name": "Jen Jackson"]
    ]
]

print("Initial JSON:\n\(JSON)\n\n")

/*:
We can instantiate `User` using one of provided initializers:
- `init(JSONDictionary: [String: AnyObject])`
- `init?(JSONString: String)`
*/

let user = User(JSONDictionary: JSON)!

print("Decoded: \n\(user)\n\n")

/*:
And encode it to JSON using one of the provided methods:
- `func JSONEncode() throws -> AnyObject`
- `func JSONString() throws -> String`
*/

do {
    let dict = try user.toJSON()
    print("Encoded: \n\(dict as! [String: AnyObject])\n\n")
}
catch {
    print("Error: \(error)")
}

//do {
//    let string = try user.JSONString()
//    print(string)
//
//    let userAgain = User(JSONString: string)
//    print(userAgain)
//} catch {
//    print("Error: \(error)")
//}

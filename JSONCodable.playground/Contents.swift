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
  func toJSON() throws -> Any {
    return try JSONEncoder.create({ (encoder) -> Void in
      try encoder.encode(id, key: "id")
      try encoder.encode(name, key: "full_name")
      try encoder.encode(email, key: "email")
      try encoder.encode(company, key: "company")
      try encoder.encode(friends, key: "friends")
    })
  }
}

extension Company: JSONEncodable {}

/*:
The default implementation of `func toJSON()` inspects the properties of your type using reflection. (Like in `Company`.) If you need a different mapping, you can provide your own implementation (like in `User`.)
*/

/*:
## JSONDecodable
We'll add conformance to `JSONDecodable`. You may also add conformance to `JSONCodable`.
*/

extension User: JSONDecodable {
  init(object: JSONObject) throws {
    let decoder = JSONDecoder(object: object)
    id = try decoder.decode("id")
    name = try decoder.decode("full_name")
    email = try decoder.decode("email")
    company = try decoder.decode("company")
    friends = try decoder.decode("friends")
  }
}

extension Company: JSONDecodable {
  init(object: JSONObject) throws {
    let decoder = JSONDecoder(object: object)
    name = try decoder.decode("name")
    address = try decoder.decode("address")
  }
}

/*:
Simply provide the implementations for `init?(JSONDictionary: JSONObject)`. As before, you can use this to configure the mapping between keys in the `Dictionary` to properties in your structs and classes.
*/

/*:
## Test Drive

You can open the console and see the output using `CMD + SHIFT + Y` or ⇧⌘Y.
Let's work with an incoming JSON Dictionary:
*/

let JSON: [String: Any] = [
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
- `init(JSONDictionary: JSONObject)`
- `init?(JSONString: String)`
*/

let user = try! User(object: JSON)
print("Decoded: \n\(user)\n\n")

/*:
And encode it to JSON using one of the provided methods:
- `func JSONEncode() throws -> AnyObject`
- `func JSONString() throws -> String`
*/

try! 1.toJSON()

let dict = try! user.toJSON()
print("Encoded: \n\(dict as! JSONObject)\n\n")

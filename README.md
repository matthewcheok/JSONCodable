#JSONCodable
Hassle-free JSON encoding and decoding in Swift

**Swift 2.0 Required**
This project uses a variety of Swift features including *Protocol Extensions* and *Error Handling* available in Swift 2.0

**Breaking Change**
`JSONCodable` now supports `let` properties. You now implement `init?(JSONDictionary: [String:AnyObject])` instead of `func JSONDecode()` and `func toJSON()` instead of `func JSONEncode()`.

---

`JSONCodable` is made of two separate protocols `JSONEncodable` and `JSONDecodable`.
`JSONEncodable` allows your structs and classes to generate `NSDictionary` or `[String: AnyObject]` equivalents for use with `NSJSONSerialization`.
`JSONDecodable` allows you to generate structs from `NSDictionary` coming in from a network request for example.

We'll use the following models in this example:
```
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
```

## Using JSONEncodable

Simply add conformance to `JSONEncodable` (or to `JSONCodable`):

```
extension User: JSONEncodable {
    func JSONEncode() throws -> AnyObject {
        var result: [String: AnyObject] = [:]
        try result.encode(id, key: "id")
        try result.encode(name, key: "full_name")
        try result.encode(email, key: "email")
        try result.encode(company, key: "company")
        try result.encode(friends, key: "friends")
        return result
    }
}

extension Company: JSONEncodable {}
```

The default implementation of `func toJSON()` inspects the properties of your type using reflection (see `Company`.) If you need a different mapping, you can provide your own implementation (see `User`.)

Instantiate your struct, then use the `func toJSON()` method to obtain a equivalent form suitable for use with `NSJSONSerialization`:
```
let dict = try user.toJSON()
print("dict: \(dict)")
```

Result:
```
[full_name: John Appleseed, id: 24, email: john@appleseed.com, company: {
    address = "1 Infinite Loop, Cupertino, CA";
    name = Apple;
}, friends: (
        {
        friends =         (
        );
        "full_name" = "Bob Jefferson";
        id = 27;
    },
        {
        friends =         (
        );
        "full_name" = "Jen Jackson";
        id = 29;
    }
)]
```

##Using JSONDecodable

Simply add conformance to `JSONDecodable` (or to `JSONCodable`):
```
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
```

Simply provide the implementations for `init?(JSONDictionary: [String:AnyObject])`.
As before, you can use this to configure the mapping between keys in the Dictionary to properties in your structs and classes.

```
let user = User(JSONDictionary: JSON)
print("\(user)")
```

Result:
```
User(
  id: 24,
  name: "John Appleseed",
  email: Optional("john@appleseed.com"),
  company: Optional(Company(
    name: "Apple",
    address: Optional("1 Infinite Loop, Cupertino, CA")
  )),
  friends: [
    User(
      id: 27,
      name: "Bob Jefferson",
      email: nil,
      company: nil,
      friends: []
    ),
    User(
      id: 29,
      name: "Jen Jackson",
      email: nil,
      company: nil,
      friends: []
    )
  ]
)
```

## Working with JSON Strings
The convenience initializer `init?(JSONString: String)` is provided on `JSONDecodable`. You may also use `func toJSONString() throws -> String` to obtain a string equivalent of your types.

## Transforming values

To transform values, create an instance of `JSONTransformer`:

```
let JSONTransformerStringToNSURL = JSONTransformer<String, NSURL>(
        decoding: {NSURL(string: $0)},
        encoding: {$0.absoluteString})
```

A `JSONTransformer` converts between 2 types, in this case, `String` and `NSURL`. It takes a closure for decoding and another for encoding, and in each case, you return an optional value of the corresponding type given an input type (you can return `nil` if a transformation is not possible).

Next, use the overloaded versions of `func encode()` and `func decode()` to supply the transformer:

```
struct User {
  ...
  var website: NSURL?
}

init?(JSONDictionary: [String : AnyObject]) {
    do {
        ...
        website = try JSONDictionary.decode("website", transformer: JSONTransformerStringToNSURL)
    }
    ...
}

func toJSON() throws -> AnyObject {
    var result = [String: AnyObject]()
    ...
    try result.encode(website, key: "website", transformer: JSONTransformerStringToNSURL)
    return result
}
```

The following transformers are provided by default:

`JSONTransformers.StringToNSURL`: `String <-> NSURL`
`JSONTransformers.StringToNSDate`: `String <-> NSDate` ISO format

Feel free to suggest more!

## Example code

Refer to the `Demo` project in the workspace for more information.
You might experience issues executing the playground in Xcode 7.0 Beta.

## License

`JSONCodable` is under the MIT license.

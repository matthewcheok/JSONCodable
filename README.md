#JSONCodable
Hassle-free JSON encoding and decoding in Swift

**Swift 2.0 required**
This project uses a variety of Swift features including *Protocol Extensions* and *Error Handling* available in Swift 2.0

`JSONCodable` is made of two separate protocols `JSONEncodable` and `JSONDecodable`.
`JSONEncodable` allows your structs and classes to generate `NSDictionary` or `[String: AnyObject]` equivalents for use with `NSJSONSerialization`.
`JSONDecodable` allows you to generate structs from `NSDictionary` coming in from a network request for example.

We'll use the following models in this example:
```
struct User {
    var id: Int = 0
    var name: String = ""
    var email: String?
    var company: Company?
    var friends: [User] = []
}

struct Company {
    var name: String = ""
    var address: String?
}
```

## Using JSONEncodable

Simply add conformance to `JSONEncodable` (or to `JSONCodable`):

```
extension User: JSONEncodable {
    func JSONEncode() throws -> AnyObject {
        var result: [String: AnyObject] = [:]
        try result.archive(id, key: "id")
        try result.archive(name, key: "full_name")
        try result.archive(email, key: "email")
        try result.archive(company, key: "company")
        try result.archive(friends, key: "friends")
        return result
    }
}

extension Company: JSONEncodable {}
```

The default implementation of `func JSONEncode()` inspects the properties of your type using reflection (see `Company`.) If you need a different mapping, you can provide your own implementation (see `User`.)

Instantiate your struct, then use the `func JSONEncode()` method to obtain a equivalent form suitable for use with `NSJSONSerialization`:
```
let dict = try user.JSONEncode()
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
    mutating func JSONDecode(JSONDictionary: [String : AnyObject]) {
        JSONDictionary.restore(&id, key: "id")
        JSONDictionary.restore(&name, key: "full_name")
        JSONDictionary.restore(&email, key: "email")
        JSONDictionary.restore(&company, key: "company")
        JSONDictionary.restore(&friends, key: "friends")
    }
}

extension Company: JSONDecodable {
    mutating func JSONDecode(JSONDictionary: [String : AnyObject]) {
        JSONDictionary.restore(&name, key: "name")
        JSONDictionary.restore(&address, key: "address")
    }
}
```

Unlike in `JSONEncodable`, you **must** provide the implementations for `func JSONDecode()`.
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

The convenience initializer `init(JSONDictionary: [String: AnyObject])` is provided.


**Limitations**

1. Your types must be initializable without any parameters, i.e. implement `init()`. You can do this by either providing a default value for all your properties or implement `init()` directly and configuring your properties at initialization.

2. You must use `var` instead of `let` when declaring properties.

`JSONDecodable` needs to be able to create new instances of your types and set their values thereafter.

Refer to the included playground for more information.

## License

`JSONCodable` is under the MIT license.

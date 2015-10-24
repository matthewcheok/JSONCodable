<p align="center">
    <img src="https://github.com/matthewcheok/JSONCodable/raw/master/logo.png" alt="Logo" width="418" height="50">
</p>
<p align="center">
    <img src="https://img.shields.io/cocoapods/p/JSONCodable.svg" alt="Platform">
    <img src="https://img.shields.io/badge/language-swift-orange.svg"
         alt="Language">
    <a href="https://cocoapods.org/pods/JSONCodable">
        <img src="https://img.shields.io/cocoapods/v/JSONCodable.svg"
             alt="CocoaPods">
    </a>
    <a href="https://github.com/Carthage/Carthage">
        <img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"
             alt="Carthage">
    </a>
    <img src="https://img.shields.io/badge/license-MIT-000000.svg"
         alt="License">
</p>

#JSONCodable
Hassle-free JSON encoding and decoding in Swift

### Installation

- Simply add the following to your [`Cartfile`](https://github.com/Carthage/Carthage) and run `carthage update`:
```
github "matthewcheok/JSONCodable"
```

- or add the following to your [`Podfile`](http://cocoapods.org/) and run `pod install`:
```
pod 'JSONCodable', '~> 2.0'
```

- or clone as a git submodule,

- or just copy files in the ```JSONCodable``` folder into your project.


**TLDR**
- Uses Protocol Extensions
- Error Handling
- Supports `let` properties
- Supports `enum` properties backed by compatible values

**Change Log**
- Moved encoding and decoding methods to a helper class

---

`JSONCodable` is made of two separate protocols `JSONEncodable` and `JSONDecodable`.
`JSONEncodable` allows your structs and classes to generate `NSDictionary` or `[String: AnyObject]` equivalents for use with `NSJSONSerialization`.
`JSONDecodable` allows you to generate structs from `NSDictionary` coming in from a network request for example.

We'll use the following models in this example:
```swift
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

```swift
extension User: JSONEncodable {
    func toJSON() throws -> AnyObject {
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
```

The default implementation of `func toJSON()` inspects the properties of your type using reflection (see `Company`.) If you need a different mapping, you can provide your own implementation (see `User`.)

Instantiate your struct, then use the `func toJSON()` method to obtain a equivalent form suitable for use with `NSJSONSerialization`:
```swift
let dict = try user.toJSON()
print("dict: \(dict)")
```

Result:
```swift
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
```swift
extension User: JSONDecodable {
    init?(JSONDictionary: JSONObject) {
        let decoder = JSONDecoder(object: JSONDictionary)
        do {
            id = try decoder.decode("id")
            name = try decoder.decode("full_name")
            email = try decoder.decode("email")
            company = try decoder.decode("company")
            friends = try decoder.decode("friends")
        }
        catch {
            return nil
        }
    }
}

extension Company: JSONDecodable {
    init?(JSONDictionary: JSONObject) {
        let decoder = JSONDecoder(object: JSONDictionary)
        do {
            name = try decoder.decode("name")
            address = try decoder.decode("address")
        }
        catch {
            return nil
        }
    }
}
```

Simply provide the implementations for `init?(JSONDictionary: JSONObject)` where `JSONObject` is a typealias for `[String:AnyObject]`.
As before, you can use this to configure the mapping between keys in the Dictionary to properties in your structs and classes.

```swift
let user = User(JSONDictionary: JSON)
print("\(user)")
```

Result:
```swift
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

```swift
let JSONTransformerStringToNSURL = JSONTransformer<String, NSURL>(
        decoding: {NSURL(string: $0)},
        encoding: {$0.absoluteString})
```

A `JSONTransformer` converts between 2 types, in this case, `String` and `NSURL`. It takes a closure for decoding and another for encoding, and in each case, you return an optional value of the corresponding type given an input type (you can return `nil` if a transformation is not possible).

Next, use the overloaded versions of `func encode()` and `func decode()` to supply the transformer:

```swift
struct User {
  ...
  var website: NSURL?
}

init?(JSONDictionary: JSONObject) {
    let decoder = JSONDecoder(object: JSONDictionary)
    do {
        ...
        website = try JSONDictionary.decode("website", transformer: JSONTransformerStringToNSURL)
    }
    catch {
        return nil
    }
}

func toJSON() throws -> AnyObject {
    return try JSONEncoder.create({ (encoder) -> Void in
        ...
        try result.encode(website, key: "website", transformer: JSONTransformerStringToNSURL)
    })
}
```

The following transformers are provided by default:

- `JSONTransformers.StringToNSURL`: `String <-> NSURL`
- `JSONTransformers.StringToNSDate`: `String <-> NSDate` ISO format

Feel free to suggest more!

## Example code

Refer to the included playground in the workspace for more details.

## License

`JSONCodable` is under the MIT license.

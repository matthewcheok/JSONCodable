# JSONEncodable
Hassle-free JSON encoding in Swift

**Swift 2.0 required**

## Using JSONEncodable

Simply add conformance to the `JSONEncodable` protocol:

```
struct User: JSONEncodable {
    let id: Int
    let name: String
    let email: String?
    let company: Company?
    let friends: [User]
}

struct Company: JSONEncodable {
    let name: String
    let address: String?
}

let john = User(id: 24, name: "John Appleseed", email: "john@appleseed.com", company: Company(name: "Apple", address: nil), friends: [
    User(id: 27, name: "Bob", email: nil, company: nil, friends: []),
    User(id: 29, name: "Jen", email: nil, company: nil, friends: []),
    ])
```

Then use the `func JSONEncoded()` method to obtain a equivalent form suitable for use with `NSJSONSerialization`:

```
let dict = try john.JSONEncoded()
print("dict: \(dict)")
```

Result:

```
{
    company =     {
        name = Apple;
    };
    email = "john@appleseed.com";
    friends =     (
                {
            friends =             (
            );
            id = 27;
            name = Bob;
        },
                {
            friends =             (
            );
            id = 29;
            name = Jen;
        }
    );
    id = 24;
    name = "John Appleseed";
}
```

Refer to the included playground for more information.

## License

`JSONEncodable` is under the MIT license.

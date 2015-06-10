# JSONEncodable
Hassle-free JSON encoding in Swift

**Swift 2.0 required**

## Using JSONEncodable

Simply add conformance to the `JSONEncodable` protocol:

```
struct Company: JSONEncodable {
    let name: String
    let address: String?
}
```

Then use the `func JSONEncoded()` method to obtain a equivalent form suitable for use with `NSJSONSerialization`:

```
let dict = try john.JSONEncoded()
print("dict: \(dict)")
```

Refer to the included playground for more information.

## License

`JSONEncodable` is under the MIT license.

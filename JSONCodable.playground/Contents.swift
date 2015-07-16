

/*:
# JSONCodable

Hassle-free JSON encoding and decoding in Swift

`JSONCodable` is made of two seperate protocols `JSONEncodable` and `JSONDecodable`.

`JSONEncodable` generates `Dictionary`s (compatible with `NSJSONSerialization`) and `String`s from your types while `JSONDecodable` creates structs (or classes) from compatible `Dictionary`s (from an incoming network request for instance)
*/

/*:
Here's some data models we'll use as an example:
*/

struct Company {
    let id:Int
    var name: String = ""
    var address: String?
}


struct User {
    var id: Int
    var name: String = ""
    var email: String?
    let company: Company?
    let friends: [User]
}


/*:
## JSONEncodable
We'll add conformance to `JSONEncodable`. You may also add conformance to `JSONCodable`.
*/


extension Company: JSONEncodable {
    func JSONEncode() throws -> AnyObject {
        var result: [String: AnyObject] = [:]
        try result.archive(address, key: "address")
        try result.archive(id, key: "id")
        try result.archive(name, key: "name")
        
        return result
    }
}

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


//extension Company: JSONEncodable {}



/*:
The default implementation of `func JSONEncode()` inspects the properties of your type using reflection. (Like in `Company`.) If you need a different mapping, you can provide your own implementation (like in `User`.)
*/

/*:
## JSONDecodable
We'll add conformance to `JSONDecodable`. You may also add conformance to `JSONCodable`.
*/


extension Company: JSONDecodable {
    init?(JSONDictionary js:[String: AnyObject] = emptyDict()){
        do{
            //let required
            try id = mustLet(js, "id")
        }
        catch{
            print("Error: \(error)")
            return nil;
        }
        //var
        name    ?<< (js,"name")
        address ?<< (js,"address")
    }
}


extension User: JSONDecodable {
    init?(JSONDictionary js:[String: AnyObject]){
        do{
            //let required
            id      = try mustLet(js, "id")
            company = try mustLet(js,"company")
        }
        catch{
            print("Error: \(error)")
            return nil;
        }
        
        //let w/ defaults
        friends = (js,"friends") ~~ []
        
        //var
        name    ?<< (js,"full_name")
        email   ?<< (js,"email")
    }
    
}


/*:
Unlike in `JSONEncodable`, you **must** provide the implementations for `func JSONDecode()`. As before, you can use this to configure the mapping between keys in the `Dictionary` to properties in your structs and classes.
*/

/*:
**Limitations**

1. Your types must be initializable without any parameters, i.e. implement `init()`. You can do this by either providing a default value for all your properties or implement `init()` directly and configuring your properties at initialization.

2. You must use `var` instead of `let` when declaring properties.

`JSONDecodable` needs to be able to create new instances of your types and set their values thereafter.
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
        "id" : 1, //required
        "name": "Apple",
        "address": "1 Infinite Loop, Cupertino, CA"
    ],
    "friends": [
        ["id": 27, "full_name": "Bob Jefferson","company":["id" : 2, "name" : "Dropbox"]],
        ["id": 29, "full_name": "Jen Jackson"], //should fail **missing company
        [/*"id": 27,*/ "full_name": "Pluto"]    //should fail **missing company
    ],
]

print("Initial JSON:\n\(JSON)\n\n")

/*:
We can instantiate `User` using one of provided initializers:
- `init(JSONDictionary: [String: AnyObject])`
- `init?(JSONString: String)`
*/

let user = User(JSONDictionary: JSON)

print("Decoded: \n\(user)\n\n")

/*:
And encode it to JSON using one of the provided methods:
- `func JSONEncode() throws -> AnyObject`
- `func JSONString() throws -> String`
*/

do {
    let dict = try user?.JSONEncode()
    print("Encoded: \n\(dict as! [String: AnyObject])\n\n")
}
catch {
    print("Error: \(error)")
}






/*:
# JSONCodable

Hassle-free JSON encoding and decoding in Swift

`JSONCodable` is made of two seperate protocols `JSONEncodable` and `JSONDecodable`.

`JSONEncodable` generates `Dictionary`s (compatible with `NSJSONSerialization`) and `String`s from your types while `JSONDecodable` creates structs (or classes) from compatible `Dictionary`s (from an incoming network request for instance)
*/

/*:
Here's some data models we'll use as an example:
*/


let emptyDict:() -> [String:AnyObject] = {[String:AnyObject]()}


struct Company {
    let id:Int
    var name: String = ""
    var address: String?
    
}


struct User {
    var id: Int = 0
    var name: String = ""
    var email: String?
    let company: Company?
    let friends: [User]
    let test:Int
    let test2:String
    let test3:Float
}



/*:
## JSONEncodable
We'll add conformance to `JSONEncodable`. You may also add conformance to `JSONCodable`.
*/



extension Company: JSONEncodable {
    func JSONEncode() throws -> AnyObject {
        var result: [String: AnyObject] = [:]
        try result.archive(address, key: "address")
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
        try result.archive(test, key: "test")
        try result.archive(test2, key: "test2")
        try result.archive(test3, key: "test3")
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


extension User: JSONDecodable {
    
    
    init?(JSONDictionary js:[String: AnyObject]){

        do{
            test2   = try reqLet(js, "test2")
            test3   = try reqLet(js, "test3")
            test    = (js, "test")  ~~ 0
            friends = (js,"friends") ~~ []
            company = (js,"company") ~~ Company()
        }
        catch{
            print("During Init Error: \(error)")
            return nil;
        }
        
        //var values
        id      ?<< (js, "id")//js["id"]
        name    ?<< (js,"full_name")
        email   ?<< (js,"email")
    }
    
}

extension Company: JSONDecodable {
    init?(JSONDictionary js:[String: AnyObject] = emptyDict()){
        
        do{
            try id = reqLet(js, "id")
        }
        catch{
            print("During Init Error: \(error)")
            return nil;
        }
        
        name    ?<< (js,"full_name")
        address ?<< (js,"address")
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
        "name": "Apple",
        "address": "1 Infinite Loop, Cupertino, CA"
    ],
    "friends": [
        ["id": 27, "full_name": "Bob Jefferson", "test2" : "test case 2!",
            "test3" : 3.14],
        ["id": 29, "full_name": "Jen Jackson"] //this friend throws erros b/c test2/test3 are required
    ],
    "test"  : 1985,
    "test2" : "test case 2!",
    "test3" : 3.14
]

//test  = 0
//test2 = ""
//test3 = 3.3

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




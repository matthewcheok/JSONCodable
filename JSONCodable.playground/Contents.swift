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

extension User: JSONCodable {
    mutating func JSONDecode(JSONDictionary: [String : AnyObject]) {
        JSONDictionary.restore(&id, key: "id")
        JSONDictionary.restore(&name, key: "full_name")
        JSONDictionary.restore(&email, key: "email")
        JSONDictionary.restore(&company, key: "company")
        JSONDictionary.restore(&friends, key: "friends")
    }
    
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

extension Company: JSONCodable {
    mutating func JSONDecode(JSONDictionary: [String : AnyObject]) {
        JSONDictionary.restore(&name, key: "name")
        JSONDictionary.restore(&address, key: "address")
    }
}

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

let user = User(JSONDictionary: JSON)

print("Decoded: \n\(user)\n\n")

do {
    let dict = try user.JSONEncode()
    print("Encoded: \n\(dict as! [String: AnyObject])\n\n")
}
catch {
    print("Error: \(error)")
}

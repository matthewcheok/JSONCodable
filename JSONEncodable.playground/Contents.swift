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

do {
    let dict = try john.JSONEncoded()
    print("dict: \(dict)")
}
catch {
    print("error \(error)")
}

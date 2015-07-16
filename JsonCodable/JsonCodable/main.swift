


//Define structs/types


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





//Extend as JSONEncodable, and define encodable properties



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




//Extend as JSONDecodable and define decodable properties

//Wrap required properties in Do method to catch failable



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



// Test JSON Data


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





// Decode User


let user = User(JSONDictionary: JSON)

print("Decoded: \n\(user)\n\n")





// Encode User


do {
    let dict = try user?.JSONEncode()
    print("Encoded: \n\(dict as! [String: AnyObject])\n\n")
}
catch {
    print("Error: \(error)")
}




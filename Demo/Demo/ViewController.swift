//
//  ViewController.swift
//  Demo
//
//  Created by Matthew Cheok on 18/7/15.
//  Copyright © 2015 matthewcheok. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    
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
            ],
            "website": ["url": "http://johnappleseed.com"]
        ]
        
        print("Initial JSON:\n\(JSON)\n\n")
        
        let user = User(JSONDictionary: JSON)!
        
        print("Decoded: \n\(user)\n\n")
        
        do {
            let dict = try user.toJSON()
            print("Encoded: \n\(dict as! [String: AnyObject])\n\n")
        }
        catch {
            print("Error: \(error)")
        }
        
        //do {
        //    let string = try user.JSONString()
        //    print(string)
        //
        //    let userAgain = User(JSONString: string)
        //    print(userAgain)
        //} catch {
        //    print("Error: \(error)")
        //}
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


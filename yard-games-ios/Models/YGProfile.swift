//
//  YGProfile.swift
//  yard-games-ios
//
//  Created by Brian Correa on 6/25/16.
//  Copyright © 2016 Milkshake Tech. All rights reserved.
//

import UIKit

class YGProfile: NSObject {
    
    var id: String?
    var username: String!
    var email: String!
    var image: String!
    
    func populate(profileInfo: Dictionary<String, AnyObject>) {
        
        let keys = ["id", "username", "email", "image"]
        for key in keys {
            let value = profileInfo[key]
            self.setValue(value, forKey: key)
        }
    }

}

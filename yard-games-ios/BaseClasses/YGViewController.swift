//
//  YGViewController.swift
//  yard-games-ios
//
//  Created by Brian Correa on 6/24/16.
//  Copyright © 2016 Milkshake Tech. All rights reserved.
//

import UIKit

class YGViewController: UIViewController {
    
    static var currentUser = YGProfile()
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self,
                                       selector: #selector(YGViewController.userLoggedIn(_:)),
                                       name: Constants.kUserLoggedInNotification,
                                       object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print("CurrentUserId: \(YGViewController.currentUser.id)")
        print("CurrentUserName: \(YGViewController.currentUser.email)")
        
    }
    
    func userLoggedIn(notification: NSNotification){
        if let user = notification.userInfo!["user"] as? Dictionary<String, AnyObject>{
            YGViewController.currentUser.populate(user)
        }
    }
    
    func postLoggedInNotification(currentUser: Dictionary<String, AnyObject>){
        let notification = NSNotification(
            name: Constants.kUserLoggedInNotification,
            object: nil,
            userInfo: ["user":currentUser]
        )
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.postNotification(notification)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}

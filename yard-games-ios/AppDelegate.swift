//
//  AppDelegate.swift
//  yard-games-ios
//
//  Created by Brian Correa on 6/24/16.
//  Copyright © 2016 Milkshake Tech. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        FIRApp.configure()
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let homeVc = YGHomeViewController()
        let homeNavCtr = UINavigationController(rootViewController: homeVc)
        
        self.window?.rootViewController = homeNavCtr
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func checkCurrentUser(){
        
        APIManager.checkCurrentUser { response in
            if let currentUserInfo = response["currentUser"] as? Dictionary<String, AnyObject>{
                
                //                print("\(currentUserInfo)")
                
                let currentUser = YGProfile()
                currentUser.populate(currentUserInfo)
                
                let notification = NSNotification(
                    name: Constants.kUserLoggedInNotification,
                    object: nil,
                    userInfo: ["user":currentUserInfo]
                )
                
                let notificationCenter = NSNotificationCenter.defaultCenter()
                notificationCenter.postNotification(notification)
            }
        }
        
    }

    func applicationWillResignActive(application: UIApplication) {
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        
    }

    func applicationWillEnterForeground(application: UIApplication) {
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        
    }

    func applicationWillTerminate(application: UIApplication) {
        
    }


}


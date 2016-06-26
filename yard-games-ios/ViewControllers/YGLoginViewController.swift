//
//  YGLoginViewController.swift
//  yard-games-ios
//
//  Created by Brian Correa on 6/24/16.
//  Copyright © 2016 Milkshake Tech. All rights reserved.
//

import UIKit

class YGLoginViewController: YGViewController, UITextFieldDelegate {
    
    var textFields = Array<UITextField>()
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    override func loadView(){
        
        print("Printing the VC Title: \(self.title)")
        
        let frame = UIScreen.mainScreen().bounds
        let view = UIView(frame: frame)
        view.backgroundColor = UIColor.lightGrayColor()

        if (self.title == "Login"){
            self.loadLoginView(frame, view: view)
        }
        
        if (self.title == "Register"){
            self.loadSignUpView(frame, view: view)
        }
        
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = false
    }
    
    func loadLoginView(frame: CGRect, view: UIView){
        print("loadLoginView")
        
        let padding = CGFloat(Constants.padding)
        let width = frame.size.width-2*padding
        let height = CGFloat(32)
        var y = CGFloat(Constants.origin_y)
        
        let fieldNames = ["Email", "Password"]
        
        for fieldName in fieldNames {
            
            let field = YGTextField(frame: CGRect(x: padding, y: y, width: width, height: height))
            field.delegate = self
            field.placeholder = fieldName
            let isPassword = (fieldName == "Password")
            field.secureTextEntry = isPassword
            field.returnKeyType = isPassword ? .Join : .Next
            
            view.addSubview(field)
            self.textFields.append(field)
            y += height+padding
        }
        
    }
    
    func loadSignUpView(frame: CGRect, view: UIView){
        print("loadSignUpView")
        
        let padding = CGFloat(20)
        let width = frame.size.width-2*padding
        let height = CGFloat(32)
        var y = CGFloat(120)
        
        let fieldNames = ["Username","Email","Password"]
        
        for fieldName in fieldNames {
            let field = YGTextField(frame: CGRect(x: padding, y: y, width: width, height: height))
            field.delegate = self
            field.placeholder = fieldName
            let isPassword = (fieldName == "Password")
            field.secureTextEntry = isPassword
            field.returnKeyType = isPassword ? .Join : .Next
            
            view.addSubview(field)
            self.textFields.append(field)
            y += height+padding
        }
    }
    
    func exit(){
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - UITextField Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let index = self.textFields.indexOf(textField)!
        print("textFieldShouldReturn: \(index)")
        
        if(index == self.textFields.count-1){ //Password Field, register
            
            var missingValue = ""
            var profileInfo = Dictionary<String, AnyObject>()
            for textField in self.textFields{
                if(textField.text?.characters.count == 0){
                    missingValue = textField.placeholder!
                    break
                }
                
                profileInfo[textField.placeholder!.lowercaseString] = textField.text!
            }
            
            // Incomplete:
            if(missingValue.characters.count > 0){
                print("MISSING VALUE")
                let msg = "Your forgot the missing "+missingValue
                let alert = UIAlertController(title: "Missing Value",
                                              message: msg,
                                              preferredStyle: .Alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return true
            }
            
            if(self.title == "Login"){
                
                APIManager.postRequest("/account/login",
                                       params: profileInfo,
                                       completion: { error, response in
                                        
                                        if(error != nil){
                                            let errorObj = error?.userInfo
                                            let errorMsg = errorObj!["message"] as! String
                                            print("ERROR: \(errorMsg)")
                                            
                                            dispatch_async(dispatch_get_main_queue(), {
                                                let alert = UIAlertController(
                                                    title: "Error",
                                                    message: errorMsg,
                                                    preferredStyle: .Alert)
                                                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                                                self.presentViewController(alert, animated: true, completion: nil)
                                            })
                                            
                                            return
                                        }
                                        
                                        print("\(response)")
                                        
                                        if let result = response!["currentUser"] as?
                                            Dictionary<String, AnyObject>{
                                            
                                            YGViewController.currentUser.populate(result)
                                            
                                            dispatch_async(dispatch_get_main_queue(), {
                                                self.postLoggedInNotification(result)
                                                
                                                let mapVc = YGMapViewController()
                                                self.navigationController?.pushViewController(mapVc, animated: true)
                                            })
                                            
                                        }
                })
                
            }
        
            if(self.title == "Register"){
            
                APIManager.postRequest("/api/profile",
                                       params: profileInfo,
                                       completion: { error, response in
                                        
                                        print("\(response)")
                                        
                                        if let result = response!["result"] as?
                                            Dictionary<String, AnyObject>{
                                            
                                            dispatch_async(dispatch_get_main_queue(), {
                                                self.postLoggedInNotification(result)
                                                
                                                let mapVc = YGMapViewController()
                                                self.navigationController?.pushViewController(mapVc, animated: true)
                                            })  
                                        }
                                        
                })
            }
            
            return true
        }
        
        let nextField = self.textFields[index+1]
        nextField.becomeFirstResponder()
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
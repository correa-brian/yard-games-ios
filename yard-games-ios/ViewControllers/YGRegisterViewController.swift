//
//  YGRegisterViewController.swift
//  yard-games-ios
//
//  Created by Brian Correa on 6/24/16.
//  Copyright © 2016 Milkshake Tech. All rights reserved.
//

import UIKit

class YGRegisterViewController: YGViewController {

    override func loadView(){
        let frame = UIScreen.mainScreen().bounds
        let view = UIView(frame: frame)
        view.backgroundColor = UIColor.lightGrayColor()
        
        let btnCancel = UIButton(type: .Custom)
        btnCancel.frame = CGRect(x: 0, y: 20, width: 100, height: 32)
        btnCancel.setTitle("Cancel", forState: .Normal)
        btnCancel.setTitleColor(.whiteColor(), forState: .Normal)
        btnCancel.addTarget(self,
                            action: #selector(YGRegisterViewController.exit),
                            forControlEvents: .TouchUpInside)
        view.addSubview(btnCancel)
        
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func exit(){
        print("exit")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

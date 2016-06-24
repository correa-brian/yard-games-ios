//
//  YGHomeViewController.swift
//  yard-games-ios
//
//  Created by Brian Correa on 6/24/16.
//  Copyright © 2016 Milkshake Tech. All rights reserved.
//

import UIKit

class YGHomeViewController: YGViewController, UIScrollViewDelegate {
    
    var loginButtons = Array<UIButton>()
    var appNameLabel: UILabel!
    var backgroundScrollView: UIScrollView!
    var pageControl: UIPageControl!
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    
    }
    
    override func loadView(){
        
        let frame = UIScreen.mainScreen().bounds
        let view = UIView(frame: frame)
        view.backgroundColor = UIColor(red: 252/255, green: 108/255, blue: 85/255, alpha: 1)
        
        self.backgroundScrollView = UIScrollView(frame: frame)
        self.backgroundScrollView.contentSize = CGSize(width: frame.size.width*3, height: frame.size.height)
        self.backgroundScrollView.pagingEnabled = true
        self.backgroundScrollView.delegate = self
        view.addSubview(self.backgroundScrollView)
        
        let padding = CGFloat(25)
        let width = frame.size.width-2*padding
        let height = CGFloat(44)
        var y = CGFloat(frame.size.height*0.75)
        
        self.pageControl = UIPageControl(frame: CGRect(x: padding, y: y-3*padding, width: width, height: 20))
        self.pageControl.numberOfPages = 3
        self.pageControl.currentPage = 0
        self.pageControl.alpha = 1
        view.addSubview(self.pageControl)
        
        self.appNameLabel = UILabel(frame: CGRect(x: padding, y: y-2*padding, width: width, height: 44))
        self.appNameLabel.textAlignment = .Center
        self.appNameLabel.text = "Yard Games"
        self.appNameLabel.font = UIFont(name: "TrebuchetMS", size: 20)
        self.appNameLabel.textColor = UIColor.whiteColor()
        view.addSubview(self.appNameLabel)
        
        let buttonTitles = ["Already have an account? Sign in", "Join with Email"]
        for btnTitle in buttonTitles {
            let btn = YGButton(frame: CGRect(x:padding, y: y, width: width, height: height))
            btn.setTitle(btnTitle, forState: .Normal)
            btn.addTarget(self, action: #selector(YGHomeViewController.btnAction(_:)), forControlEvents: .TouchUpInside)
            view.addSubview(btn)
            self.loginButtons.append(btn)
            y += height + padding
        }
        
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true

    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView){
        print("scrollViewDidEndDecelerating: \(scrollView.contentOffset.x)")
        let offset = scrollView.contentOffset.x
        
        if (offset == 0){
            self.view.backgroundColor = UIColor(red: 252/255, green: 108/255, blue: 85/255, alpha: 1)
        }
        
        if (offset == self.view.frame.size.width){
            self.view.backgroundColor = UIColor.blueColor()
            self.pageControl.currentPage = 1
        }
        
        if (offset == self.view.frame.size.width*2){
            self.view.backgroundColor = UIColor.blackColor()
            self.pageControl.currentPage = 2
        }
    }
    
    func btnAction(sender: UIButton){
        
        let buttonTitle = sender.titleLabel?.text?.lowercaseString
        print("\(buttonTitle)")
        
        if(buttonTitle == "join with email"){
            print("JOIN")
            let registerVc = YGRegisterViewController()
            self.presentViewController(registerVc, animated: true, completion: nil)
        }
        
        if(buttonTitle == "already have an account? sign in"){
            print("LOGIN")
            let loginVc = YGLoginViewController()
            self.presentViewController(loginVc, animated: true, completion: nil)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}

//
//  YGChatViewController.swift
//  yard-games-ios
//
//  Created by Brian Correa on 6/26/16.
//  Copyright © 2016 Milkshake Tech. All rights reserved.
//

import UIKit
import Firebase

class YGChatViewController: YGViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    //MARK: - Firebase Config:
    var firebase: FIRDatabaseReference! // establishes connection and maintains connection to DB
    var _refHandle: UInt!
    
    // MARK: - Properties

    var place: YGPlace!
    var chatTable: UITableView!
    var posts = Array<YGPost>()
    var keys = Array<String>()
    
    var bottomView: UIView!
    var messageField: UITextField!
    
    // MARK: - Lifecycle Methods
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.hidesBottomBarWhenPushed = true
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(
            self,
            selector: #selector(YGChatViewController.shiftKeyboardUp(_:)),
            name: UIKeyboardWillShowNotification,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(YGChatViewController.shiftKeyboardDown(_:)),
            name: UIKeyboardWillHideNotification,
            object: nil
        )
    }
    
    override func loadView(){
        let frame = UIScreen.mainScreen().bounds
        let view = UIView(frame: frame)
        view.backgroundColor = .grayColor()
        
        self.chatTable = UITableView(frame: frame, style: .Plain)
        self.chatTable.dataSource = self
        self.chatTable.delegate = self
        self.chatTable.registerClass(YGChatTableViewCell.classForCoder(), forCellReuseIdentifier: "cellId")
        view.addSubview(self.chatTable)
        
        let height = CGFloat(44)
        let width = frame.size.width
        
        let y = frame.size.height //offscreen bounds; will animate in
        self.bottomView = UIView(frame: CGRect(x: 0, y: y, width: width, height: height))
        self.bottomView.autoresizingMask = .FlexibleTopMargin
        self.bottomView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        view.addSubview(bottomView)
        
        let padding = CGFloat(6)
        let btnWidth = CGFloat(80)
        
        self.messageField = UITextField(frame: CGRect(x: padding, y: padding, width: width-2*padding-btnWidth, height: height-2*padding))
        self.messageField.borderStyle = .RoundedRect
        self.messageField.placeholder = "Post a Message"
        self.messageField.delegate = self
        self.bottomView.addSubview(self.messageField)
        
        let btnSend = UIButton(type: .Custom)
        btnSend.frame = CGRect(x: width-btnWidth, y: padding, width: 74, height: height-2*padding)
        btnSend.setTitle("Send", forState: .Normal)
        btnSend.backgroundColor = UIColor.lightGrayColor()
        btnSend.layer.cornerRadius = 5
        btnSend.layer.masksToBounds = true
        btnSend.layer.borderColor = UIColor.darkGrayColor().CGColor
        btnSend.layer.borderWidth = 0.5
        self.bottomView.addSubview(btnSend)
        btnSend.addTarget(self, action: #selector(YGChatViewController.postMessage), forControlEvents: .TouchUpInside)
        
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firebase = FIRDatabase.database().reference() // initialize FB manager
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        print("viewWillAppear:")
        
        //Listen for new messages in the FB DB
        self._refHandle = self.firebase.child(self.place.id).queryLimitedToLast(25).observeEventType(.Value, withBlock: { (snapshot) -> Void in
            
            if let payload = snapshot.value as? Dictionary<String, AnyObject> {
                
                for key in payload.keys {
                    let postInfo = payload[key] as! Dictionary<String, AnyObject>
//                    print("POST == \(post)")
                    if(self.keys.contains(key)){
                        continue
                    }
                    
                    self.keys.append(key)
                    let post = YGPost()
                    post.id = key
                    post.populate(postInfo)
                    self.posts.append(post)
                    
                }
                
                print("\(self.posts.count) POSTS")
                self.posts.sortInPlace{
                    $0.timestamp.compare($1.timestamp) == .OrderedAscending
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.chatTable.reloadData()
                })
            }
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        print("viewDidAppear")
        UIView.animateWithDuration(0.35,
                                   delay: 0.25,
                                   options: UIViewAnimationOptions.CurveLinear,
                                   animations: {
                                    var bottomFrame = self.bottomView.frame
                                    bottomFrame.origin.y = bottomFrame.origin.y-self.bottomView.frame.size.height
                                    self.bottomView.frame = bottomFrame
            },
                                   completion: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.firebase.removeObserverWithHandle(self._refHandle)
        
    }
    
    //Helper Methods
    
    func postMessage(){
        print("postMessage")
        messageField.resignFirstResponder()
        
        //Push data to Firebase Database
        let timestamp = NSDate().timeIntervalSince1970
        let post = [
            "from": YGViewController.currentUser.id!,
            "message":self.messageField.text!,
            "timestamp": "\(timestamp)",
            "place":self.place.id
        ]
        
        self.firebase.child(self.place.id).childByAutoId().setValue(post)
        
        self.messageField.text = nil
        
    }
    
    //MARK - KeyboardNotifcations:
    
    func shiftKeyboardUp(notification: NSNotification){
        if let keyboardFrame = notification.userInfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue() {
            //            print("\(notification.userInfo!)")
            
            var frame = self.bottomView.frame
            frame.origin.y = keyboardFrame.origin.y-frame.size.height
            self.bottomView.frame = frame
        }
    }
    
    func shiftKeyboardDown(notfcation: NSNotification){
        var frame = self.bottomView.frame
        frame.origin.y = self.view.frame.size.height-frame.size.height
        self.bottomView.frame = frame
    }
    
    //MARK: - TextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        messageField.resignFirstResponder()
        
        self.postMessage()
        return true
    }
    
    //MARK: - TableView Delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.messageField.resignFirstResponder()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = self.posts[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(YGChatTableViewCell.cellId, forIndexPath: indexPath) as! YGChatTableViewCell
        cell.messageLabel.text = post.message
        cell.dateLabel.text = post.formattedDate
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
}

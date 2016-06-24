//
//  YGButton.swift
//  yard-games-ios
//
//  Created by Brian Correa on 6/24/16.
//  Copyright © 2016 Milkshake Tech. All rights reserved.
//

import UIKit

class YGButton: UIButton {
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.65)
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 7.5
        self.titleLabel?.font = UIFont(name: "Arial", size: 16)
    }

}

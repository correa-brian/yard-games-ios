//
//  YGTextField.swift
//  yard-games-ios
//
//  Created by Brian Correa on 6/25/16.
//  Copyright © 2016 Milkshake Tech. All rights reserved.
//

import UIKit

class YGTextField: UITextField {

    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let height = frame.size.height
        let width = frame.size.width
        
        self.font = UIFont(name: "Heiti SC", size: 18)
        self.autocorrectionType = .No
        
        let line = UIView(frame: CGRect(x: 0, y: height-1, width: width, height: 1))
        line.backgroundColor = .whiteColor()
        self.addSubview(line)
    }
}

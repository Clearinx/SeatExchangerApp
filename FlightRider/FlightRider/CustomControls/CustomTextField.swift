//
//  ViewController.swift
//  FlightRider
//
//  Created by Tomi on 2019. 09. 19..
//  Copyright © 2019. Tomi. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpField()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init( coder: aDecoder )
        setUpField()
    }
    
    
    private func setUpField() {
        tintColor             = .white
        textColor             = .white
        //font                  = UIFont(name: "Marker Felt", size: 18)
        backgroundColor       = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        alpha                 = 0.5
        autocorrectionType    = .no
        layer.cornerRadius    = 15.0
        clipsToBounds         = true
        
        let placeholder       = self.placeholder != nil ? self.placeholder! : ""
        let placeholderFont   = UIFont(name: "Marker Felt", size: 30)!
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes:
            [NSAttributedString.Key.foregroundColor: UIColor.white,
             NSAttributedString.Key.font: placeholderFont])
    }
}

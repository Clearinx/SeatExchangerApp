//
//  ViewController.swift
//  FlightRider
//
//  Created by Tomi on 2019. 09. 19..
//  Copyright © 2019. Tomi. All rights reserved.
//

import UIKit

class CustomLabel: UILabel {
    
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
        textColor             = #colorLiteral(red: 0.1417597532, green: 0.3963234425, blue: 0.5652638078, alpha: 1)
        font                  = UIFont(name: "MarkerFelt-Thin", size: 18)
        //backgroundColor       =
        //alpha                 = 0.5
        //layer.cornerRadius    = 15.0
        clipsToBounds         = true
    }
}

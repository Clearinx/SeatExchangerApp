//
//  ViewController.swift
//  FlightRider
//
//  Created by Tomi on 2019. 09. 19..
//  Copyright © 2019. Tomi. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    
    private func setupButton() {
        backgroundColor     = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        alpha               = 0.9
        titleLabel?.font    = UIFont(name: "Arial", size: 30)
        layer.cornerRadius  = frame.size.height * 0.35
        setTitleColor(.white, for: .normal)
    }
}

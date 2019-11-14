//
//  CustomSwitch.swift
//  FlightRider
//
//  Created by Tomi on 2019. 11. 14..
//  Copyright © 2019. Tomi. All rights reserved.
//

import UIKit

class CustomSwitch: UISwitch{
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSwitch()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSwitch()
    }
    
    func setupSwitch(){
        transform = CGAffineTransform(scaleX: (UIScreen.main.bounds.height * 0.001), y: (UIScreen.main.bounds.height * 0.001))
    }
}

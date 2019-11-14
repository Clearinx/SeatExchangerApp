//
//  CustomImageView.swift
//  FlightRider
//
//  Created by Tomi on 2019. 11. 14..
//  Copyright © 2019. Tomi. All rights reserved.
//

import UIKit

class CustomImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImage()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupImage()
    }
    
    
    private func setupImage() {
        layer.cornerRadius = UIScreen.main.bounds.height * 0.025
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.masksToBounds = true
    }
    
}

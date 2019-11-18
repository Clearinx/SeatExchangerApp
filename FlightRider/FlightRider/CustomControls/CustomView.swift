//
//  CustomView.swift
//  FlightRider
//
//  Created by Tomi on 2019. 11. 14..
//  Copyright © 2019. Tomi. All rights reserved.
//

import UIKit

class ContainerView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImage()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupImage()
    }

    private func setupImage() {
        backgroundColor     = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = .init(width: 8, height: 8)
        layer.shadowRadius = 8
        //layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.cornerRadius  = UIScreen.main.bounds.height * 0.025
    }
}

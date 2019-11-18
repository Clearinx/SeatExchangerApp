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
        textColor             = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        clipsToBounds         = true
    }
}

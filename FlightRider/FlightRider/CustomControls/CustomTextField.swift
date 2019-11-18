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
        textColor             = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        //font                  = UIFont(name: "Marker Felt", size: 18)
        backgroundColor       = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        alpha                 = 0.75
        autocorrectionType    = .no
        layer.cornerRadius    = 5.0
        clipsToBounds         = true

        let placeholder       = self.placeholder != nil ? self.placeholder! : ""
        let placeholderFont   = UIFont(name: "Arial", size: 15)!
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes:
            [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1),
             NSAttributedString.Key.font: placeholderFont])
    }
}

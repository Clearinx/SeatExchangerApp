//
//  CustomTableViewCell.swift
//  FlightRider
//
//  Created by Tomi on 2019. 11. 15..
//  Copyright © 2019. Tomi. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.contentView.backgroundColor = .clear

    }

    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame =  newFrame
            frame.origin.y += UIScreen.main.bounds.height * 0.0176
            frame.origin.x += UIScreen.main.bounds.width * 0.0468
            frame.size.height -= 2 * UIScreen.main.bounds.height * 0.0176
            frame.size.width -= 2 * UIScreen.main.bounds.width * 0.0468

            super.frame = frame
        }

    }
}

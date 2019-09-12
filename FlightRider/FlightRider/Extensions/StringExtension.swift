//
//  StringExtension.swift
//  FlightRider
//
//  Created by Tomi on 2019. 09. 12..
//  Copyright © 2019. Tomi. All rights reserved.
//

import Foundation

extension String{
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
}

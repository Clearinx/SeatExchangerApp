//
//  DateExtension.swift
//  FlightRider
//
//  Created by Tomi on 2019. 09. 05..
//  Copyright © 2019. Tomi. All rights reserved.
//

import Foundation

extension Date {
    
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    
}

//
//  Flight.swift
//  FlightRider
//
//  Created by Tomi on 2019. 10. 28..
//  Copyright © 2019. Tomi. All rights reserved.
//

import Foundation

struct Flight {
    var departureDate: Date
    var iataNumber: String
    var uid: String
    var changetag: String
    var airplaneType: String
    var seats = Set<ManagedSeat>()
}

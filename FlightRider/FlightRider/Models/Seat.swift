//
//  Seat.swift
//  FlightRider
//
//  Created by Tomi on 2019. 10. 28..
//  Copyright © 2019. Tomi. All rights reserved.
//

import Foundation

struct Seat{
    var changetag: String
    var number: String
    var occupiedBy: String
    var uid: String
    var flight: ManagedFlight?
}

//
//  Seat+CoreDataProperties.swift
//  FlightRider
//
//  Created by Tomi on 2019. 08. 14..
//  Copyright © 2019. Tomi. All rights reserved.
//
//

import Foundation
import CoreData


extension Seat {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Seat> {
        return NSFetchRequest<Seat>(entityName: "Seat")
    }

    @NSManaged public var number: String
    @NSManaged public var occupiedBy: String
    @NSManaged public var changetag: String
    @NSManaged public var uid: String
    @NSManaged public var flight: Flight
    
}

//
//  Seat+CoreDataProperties.swift
//  FlightRider
//
//  Created by Tomi on 2019. 08. 12..
//  Copyright © 2019. Tomi. All rights reserved.
//
//

import Foundation
import CoreData


extension Seat {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Seat> {
        return NSFetchRequest<Seat>(entityName: "Seat")
    }

    @NSManaged public var occupiedBy: String
    @NSManaged public var number: String

}

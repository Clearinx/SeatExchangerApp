//
//  Flight+CoreDataProperties.swift
//  FlightRider
//
//  Created by Horvath Tamas on 2019. 08. 13..
//  Copyright © 2019. Tomi. All rights reserved.
//
//

import Foundation
import CoreData


extension Flight {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Flight> {
        return NSFetchRequest<Flight>(entityName: "Flight")
    }

    @NSManaged public var checkedIn: Bool
    @NSManaged public var departureDate: Date
    @NSManaged public var iataNumber: String

}

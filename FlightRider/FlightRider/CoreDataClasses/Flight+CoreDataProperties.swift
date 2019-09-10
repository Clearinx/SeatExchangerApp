//
//  Flight+CoreDataProperties.swift
//  FlightRider
//
//  Created by Tomi on 2019. 09. 09..
//  Copyright © 2019. Tomi. All rights reserved.
//
//

import Foundation
import CoreData


extension Flight {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Flight> {
        return NSFetchRequest<Flight>(entityName: "Flight")
    }

    @NSManaged public var departureDate: Date
    @NSManaged public var iataNumber: String
    @NSManaged public var uid: String
    @NSManaged public var changetag: String
    @NSManaged public var airplaneType: String
    @NSManaged public var seats: Set<Seat>

}

// MARK: Generated accessors for seats
extension Flight {

    @objc(addSeatsObject:)
    @NSManaged public func addToSeats(_ value: Seat)

    @objc(removeSeatsObject:)
    @NSManaged public func removeFromSeats(_ value: Seat)

    @objc(addSeats:)
    @NSManaged public func addToSeats(_ values: NSSet)

    @objc(removeSeats:)
    @NSManaged public func removeFromSeats(_ values: NSSet)

}

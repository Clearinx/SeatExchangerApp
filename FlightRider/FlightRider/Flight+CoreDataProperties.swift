//
//  Flight+CoreDataProperties.swift
//  FlightRider
//
//  Created by Tomi on 2019. 08. 12..
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
    @NSManaged public var seats: NSSet

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

//
//  ManagedFlight+CoreDataProperties.swift
//  
//
//  Created by Tomi on 2019. 10. 28..
//
//

import Foundation
import CoreData

extension ManagedFlight {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<ManagedFlight> {
        return NSFetchRequest<ManagedFlight>(entityName: "ManagedFlight")
    }

    @NSManaged public var departureDate: Date
    @NSManaged public var iataNumber: String
    @NSManaged public var uid: String
    @NSManaged public var changetag: String
    @NSManaged public var airplaneType: String
    @NSManaged public var seats: Set<ManagedSeat>

}

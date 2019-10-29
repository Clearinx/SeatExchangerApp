//
//  ManagedSeat+CoreDataProperties.swift
//  
//
//  Created by Tomi on 2019. 10. 28..
//
//

import Foundation
import CoreData


extension ManagedSeat {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<ManagedSeat> {
        return NSFetchRequest<ManagedSeat>(entityName: "ManagedSeat")
    }

    @NSManaged public var changetag: String
    @NSManaged public var number: String
    @NSManaged public var occupiedBy: String
    @NSManaged public var uid: String
    @NSManaged public var flight: ManagedFlight?

}

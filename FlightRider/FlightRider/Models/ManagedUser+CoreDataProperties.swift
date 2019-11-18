//
//  ManagedUser+CoreDataProperties.swift
//  
//
//  Created by Tomi on 2019. 10. 28..
//
//

import Foundation
import CoreData

extension ManagedUser {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<ManagedUser> {
        return NSFetchRequest<ManagedUser>(entityName: "ManagedUser")
    }

    @NSManaged public var email: String
    @NSManaged public var flights: [String]
    @NSManaged public var uid: String
    @NSManaged public var changetag: String

}

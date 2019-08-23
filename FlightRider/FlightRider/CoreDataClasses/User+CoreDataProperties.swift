//
//  User+CoreDataProperties.swift
//  FlightRider
//
//  Created by Tomi on 2019. 08. 22..
//  Copyright © 2019. Tomi. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var email: String
    @NSManaged public var flights: [String]
    @NSManaged public var uid: String

}

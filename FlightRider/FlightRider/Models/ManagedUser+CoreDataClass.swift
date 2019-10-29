//
//  ManagedUser+CoreDataClass.swift
//  
//
//  Created by Tomi on 2019. 10. 28..
//
//

import Foundation
import CoreData

@objc(ManagedUser)
public class ManagedUser: NSManagedObject {
    
    func toUser() -> User
    {
        return User(email: email, flights: flights, uid: uid, changetag: changetag)
    }
    
    func fromUser(user: User)
    {
        email = user.email
        flights = user.flights
        uid = user.uid
        changetag = user.changetag
    }

}

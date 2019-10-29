//
//  ManagedFlight+CoreDataClass.swift
//  
//
//  Created by Tomi on 2019. 10. 28..
//
//

import Foundation
import CoreData

@objc(ManagedFlight)
public class ManagedFlight: NSManagedObject {
    
    func toFlight() -> Flight
    {
        return Flight(departureDate: departureDate, iataNumber: iataNumber, uid: uid, changetag: changetag, airplaneType: airplaneType, seats: seats)
    }
    
    func fromFlight(flight: Flight)
    {
        departureDate = flight.departureDate
        iataNumber = flight.iataNumber
        uid = flight.uid
        changetag = flight.changetag
        airplaneType = flight.airplaneType
        seats = flight.seats
    }
    
    

}

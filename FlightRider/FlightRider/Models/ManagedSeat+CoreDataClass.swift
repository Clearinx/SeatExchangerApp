//
//  ManagedSeat+CoreDataClass.swift
//  
//
//  Created by Tomi on 2019. 10. 28..
//
//

import Foundation
import CoreData

@objc(ManagedSeat)
public class ManagedSeat: NSManagedObject {

    func toSeat() -> Seat {
        return Seat(changetag: changetag, number: number, occupiedBy: occupiedBy, uid: uid, flight: flight)
    }

    func fromSeat(seat: Seat) {
        changetag = seat.changetag
        number = seat.number
        occupiedBy = seat.occupiedBy
        uid = seat.uid
        flight = seat.flight
    }

}

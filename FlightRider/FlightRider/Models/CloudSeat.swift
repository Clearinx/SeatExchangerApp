//
//  CloudSeat.swift
//  FlightRider
//
//  Created by Tomi on 2019. 11. 04..
//  Copyright © 2019. Tomi. All rights reserved.
//

import Foundation
import CloudKit

class CloudSeat{
    
    let seatRecord = CKRecord(recordType: "Seat")
    
    let number : String
    let occupiedBy : String
    let flight : CKRecord.Reference
    
    init(number: String, occupiedBy: String, flight: CKRecord.Reference) {
        self.number = number
        seatRecord["number"] = number as CKRecordValue
        self.occupiedBy = occupiedBy
        seatRecord["occupiedBy"] = occupiedBy as CKRecordValue
        self.flight = flight
        seatRecord["flight"] = flight as CKRecordValue
    }
    
}

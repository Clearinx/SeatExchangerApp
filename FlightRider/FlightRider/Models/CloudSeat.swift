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
    
    var seatRecord : CKRecord
    
    let number : String
    let occupiedBy : String
    let flightID: CKRecord.ID
    
    init(number: String, occupiedBy: String, flightID: CKRecord.ID) {
        self.seatRecord = CKRecord(recordType: "Seat")
        self.number = number
        seatRecord["number"] = number as CKRecordValue
        self.occupiedBy = occupiedBy
        seatRecord["occupiedBy"] = occupiedBy as CKRecordValue
        self.flightID = flightID
        seatRecord["flight"] = CKRecord.Reference(recordID: flightID, action: .none)
    }
    
    init(record: CKRecord) {
        self.seatRecord = record
        self.number = seatRecord["number"]!
        self.occupiedBy = seatRecord["occupiedBy"]!
        self.flightID = (seatRecord["flight"]! as CKRecord.Reference).recordID
    }
    
}

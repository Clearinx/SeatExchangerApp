//
//  CloudFlight.swift
//  FlightRider
//
//  Created by Tomi on 2019. 11. 05..
//  Copyright © 2019. Tomi. All rights reserved.
//

import Foundation
import CloudKit

class CloudFlight{
    
    var flightRecord : CKRecord
    
    var airplaneType : String
    var departureDate : Date
    var iataNumber: String
    var seats : [CKRecord.Reference]
    
    init(airplaneType: String, departureDate: Date, iataNumber: String, seats: [CKRecord.Reference]) {
        self.flightRecord = CKRecord(recordType: "Flight")
        self.airplaneType = airplaneType
        flightRecord["airplaneType"] = airplaneType as CKRecordValue
        self.departureDate = departureDate
        flightRecord["departureDate"] = departureDate as CKRecordValue
        self.iataNumber = iataNumber
        flightRecord["iataNumber"] = iataNumber as CKRecordValue
        self.seats = seats
         flightRecord["seats"] = seats
    }
    
    init(record: CKRecord) {
        self.flightRecord = record
        self.airplaneType = flightRecord["airplaneType"]!
        self.departureDate = flightRecord["departureDate"]!
        self.iataNumber = flightRecord["iataNumber"]!
        self.seats = flightRecord["seats"]!
    }
    
}

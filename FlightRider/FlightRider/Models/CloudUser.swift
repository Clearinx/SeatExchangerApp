//
//  CloudSeat.swift
//  FlightRider
//
//  Created by Tomi on 2019. 11. 04..
//  Copyright © 2019. Tomi. All rights reserved.
//

import Foundation
import CloudKit

class CloudUser{
    
    var userRecord : CKRecord
    
    var email : String!
    var uid : String!
    var flights: [String]!
    
    init(email: String, uid: String, flights: [String]) {
        self.userRecord = CKRecord(recordType: "AppUsers")
        self.email = email
        userRecord["email"] = email as CKRecordValue
        self.uid = uid
        userRecord["uid"] = uid as CKRecordValue
        self.flights = flights
        userRecord["flights"] = flights as CKRecordValue
    }
    
    init(record: CKRecord) {
        self.userRecord = record
        self.email = userRecord["email"]!
        self.uid = userRecord["uid"]!
        self.flights = userRecord["flights"] ?? [String]()
    }
    
    init() {
        self.userRecord = CKRecord(recordType: "User")
    }
    
}

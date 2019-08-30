//
//  ViewControllerFlightExtension.swift
//  FlightRider
//
//  Created by Tomi on 2019. 08. 30..
//  Copyright © 2019. Tomi. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

extension ViewController {

    func saveFlightDataToBothDb(params: [String]){
        
        let flightRecord = CKRecord(recordType: "Flights")

        let flight = Flight(context: self.container.viewContext)
        flight.uid = flightRecord.recordID.recordName
        flight.iataNumber = params[0]
        let departureDate = params[1]
        let dateFormat = getDate(receivedDate: departureDate)
        flight.departureDate = dateFormat
        flight.seats = Set<Seat>()
        var recordsToSave = generateSeats(flight: flight, flightRecord: flightRecord)
        flight.changetag = ""
        
        flightRecord["uid"] = flightRecord.recordID.recordName
        flightRecord["iataNumber"] = flight.iataNumber as CKRecordValue
        flightRecord["departureDate"] = flight.departureDate as CKRecordValue
        recordsToSave.append(flightRecord)
        self.saveRecords(records: recordsToSave)
        self.saveContext()
        
}
    func generateSeats(flight : Flight, flightRecord : CKRecord) -> [CKRecord]{
        //just dummy values right now
        let seat = Seat(context: self.container.viewContext)
        seat.number = "13C"
        seat.occupiedBy = "AAA"
        seat.flight = flight
        
        let seatRecord = CKRecord(recordType: "Seat")
        seatRecord["number"] = seat.number as CKRecordValue
        seatRecord["occupiedBy"] = seat.occupiedBy as CKRecordValue
        seatRecord["flight"] = CKRecord.Reference(recordID: flightRecord.recordID, action: .none)

        
        let seat2 = Seat(context: self.container.viewContext)
        seat2.number = "13F"
        seat2.occupiedBy = "BBB"
        seat.flight = flight
        
        let seat2Record = CKRecord(recordType: "Seat")
        seat2Record["number"] = seat.number as CKRecordValue
        seat2Record["occupiedBy"] = seat.occupiedBy as CKRecordValue
        seat2Record["flight"] = CKRecord.Reference(recordID: flightRecord.recordID, action: .none)
        
        
        flight.seats.insert(seat)
        flight.seats.insert(seat2)
        
        var seatReferences = [CKRecord.Reference]()
        seatReferences.append(CKRecord.Reference(recordID: seatRecord.recordID, action: .none))
        seatReferences.append(CKRecord.Reference(recordID: seat2Record.recordID, action: .none))
        flightRecord["seats"] = seatReferences
        
        var seatRecords = [CKRecord]()
        seatRecords.append(seatRecord)
        seatRecords.append(seat2Record)
        return seatRecords
        
    }

        func fetchFlightsFromCloud(results : [CKRecord]){
            let flight = Flight(context: self.container.viewContext)
            flight.uid = results.first!["uid"]!
            flight.iataNumber = results.first!["iataNumber"]!
            flight.departureDate = results.first!["departureDate"]!
            flight.changetag = results.first!.recordChangeTag!
            
            var seatReferences = [CKRecord.Reference]()
            seatReferences = results.first!["seats"]!
            var recordIDs = [CKRecord.ID]()

            for seatReference in seatReferences{
                recordIDs.append(seatReference.recordID)
                
            }
            let predicate = NSPredicate(format: "ANY %@ = recordID" ,recordIDs)
            
            makeCloudQuery(sortKey: "number", predicate: predicate, cloudTable: "Seat"){ cloudResults in
                for result in cloudResults{
                    let seat = Seat(context: self.container.viewContext)
                    seat.number = result["number"]!
                    seat.occupiedBy = result["occupiedBy"]!
                    seat.uid = result.recordID.recordName
                    seat.changetag = result.recordChangeTag!
                    seat.flight = flight
                    
                }
                self.saveContext()
                print(flight)
            }
         }
    
    func compareFlightsChangeTag(localResults : [NSManagedObject],  cloudResults : [CKRecord]){
        let flight = localResults.first! as! Flight
        if(flight.changetag != cloudResults.first!.recordChangeTag){
            fetchFlightsFromCloud(results : cloudResults)
        }
    }

}

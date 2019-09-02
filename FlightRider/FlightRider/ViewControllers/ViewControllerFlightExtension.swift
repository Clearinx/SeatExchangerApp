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

    func saveFlightDataToBothDb(params: [String]?){
        
        let flightRecord = CKRecord(recordType: "Flights")

        let flight = Flight(context: self.container.viewContext)
        flight.uid = flightRecord.recordID.recordName
        flight.iataNumber = params![0]
        let departureDate = params![1]
        let dateFormat = getDate(receivedDate: departureDate)
        flight.departureDate = dateFormat
        flight.seats = Set<Seat>()
        var recordsToSave = generateSeats(flight: flight, flightRecord: flightRecord)
        
        flightRecord["uid"] = flightRecord.recordID.recordName
        flightRecord["iataNumber"] = flight.iataNumber as CKRecordValue
        flightRecord["departureDate"] = flight.departureDate as CKRecordValue
        recordsToSave.append(flightRecord)
        user.flights = userRecord["flights"] ?? [String]()
        user.flights.append(flight.iataNumber)
        print(userRecord)
        userRecord["flights"] = user.flights as CKRecordValue
        print(userRecord)
        recordsToSave.append(userRecord)
        let semaphore = DispatchSemaphore(value: 0)
        self.saveRecords(records: recordsToSave){
            self.user.changetag = self.userRecord.recordChangeTag!
            flight.changetag = flightRecord.recordChangeTag!
            for i in 0...flight.seats.count-1{
                let seatsArray = Array(flight.seats)
                seatsArray[i].changetag = recordsToSave[i].recordChangeTag!
            }
            self.saveContext()
            semaphore.signal()
        }
        semaphore.wait()
        
        
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
        seat2.flight = flight
        
        let seat2Record = CKRecord(recordType: "Seat")
        seat2Record["number"] = seat.number as CKRecordValue
        seat2Record["occupiedBy"] = seat.occupiedBy as CKRecordValue
        seat2Record["flight"] = CKRecord.Reference(recordID: flightRecord.recordID, action: .none)
        
        seat.uid = seatRecord.recordID.recordName
        seat2.uid = seat2Record.recordID.recordName
        
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
            for result in results{
                
                let flight = Flight(context: self.container.viewContext)
                flight.uid = result["uid"]!
                flight.iataNumber = result["iataNumber"]!
                flight.departureDate = result["departureDate"]!
                flight.changetag = result.recordChangeTag!
                
                var seatReferences = [CKRecord.Reference]()
                seatReferences = result["seats"]!
                var recordIDs = [CKRecord.ID]()

                for seatReference in seatReferences{
                    recordIDs.append(seatReference.recordID)
                    
                }
                let predicate = NSPredicate(format: "ANY %@ = recordID" ,recordIDs)
                let semaphore = DispatchSemaphore(value: 0)
                makeCloudQuery(sortKey: "number", predicate: predicate, cloudTable: "Seat"){ cloudResults in
                    for seatResult in cloudResults{
                        let seat = Seat(context: self.container.viewContext)
                        seat.number = seatResult["number"]!
                        seat.occupiedBy = seatResult["occupiedBy"]!
                        seat.uid = seatResult.recordID.recordName
                        seat.changetag = seatResult.recordChangeTag!
                        seat.flight = flight
                    }
                    semaphore.signal()
                }
                semaphore.wait()
                
         }
        saveContext()
    }
    
    func fetchFlightsFromCloudWaitForResult(results : [CKRecord], completionHandler: @escaping (Flight) -> Void){
        for result in results{
            let flight = Flight(context: self.container.viewContext)
            flight.uid = result["uid"]!
            flight.iataNumber = result["iataNumber"]!
            flight.departureDate = result["departureDate"]!
            flight.changetag = result.recordChangeTag!
            
            var seatReferences = [CKRecord.Reference]()
            seatReferences = result["seats"]!
            var recordIDs = [CKRecord.ID]()
            
            for seatReference in seatReferences{
                recordIDs.append(seatReference.recordID)
                
            }
            let predicate = NSPredicate(format: "ANY %@ = recordID" ,recordIDs)
            
            makeCloudQuery(sortKey: "number", predicate: predicate, cloudTable: "Seat"){ cloudResults in
                for seatResult in cloudResults{
                    let seat = Seat(context: self.container.viewContext)
                    seat.number = seatResult["number"]!
                    seat.occupiedBy = seatResult["occupiedBy"]!
                    seat.uid = seatResult.recordID.recordName
                    seat.changetag = seatResult.recordChangeTag!
                    seat.flight = flight
                }
            }
                completionHandler(flight)
        }
        
    }
    
    func fetchFlightsFromCloudAndAppendToUserList(results : [CKRecord]){
        fetchFlightsFromCloudWaitForResult(results: results){ flight in
             self.user.flights = self.userRecord["flights"]!
             self.user.flights.append(flight.iataNumber)
             self.userRecord["flights"] = self.user.flights as CKRecordValue
             let recordsToSave = [self.userRecord]
             self.saveRecords(records: recordsToSave){
                self.user.changetag = self.userRecord.recordChangeTag!
                self.saveContext()
            }
        }
    }
    
    func compareFlightsChangeTag(localResults : [NSManagedObject],  cloudResults : [CKRecord]){
        if localResults.count == cloudResults.count{
            for i in 0...localResults.count - 1{
                let flight = localResults[i] as! Flight
                if(flight.changetag != cloudResults[i].recordChangeTag){
                    fetchFlightsFromCloud(results : cloudResults)
                }
            }

        }
    }
    
    func deleteFlightsFromLocalDb(localResults : [NSManagedObject]){
        for result in localResults{
            let flight = result as! Flight
            for seat in flight.seats{
                container.viewContext.delete(seat)
            }
            container.viewContext.delete(result)
        }
        saveContext()

    }
    func doNothing(params: [String]?){
        
    }
        
}

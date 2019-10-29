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

        //let flight = Flight(context: self.container.viewContext)
        let departureDate = params![1]
        let dateFormat = getDate(receivedDate: departureDate)
        var flight = Flight(departureDate: dateFormat, iataNumber: params![0], uid: flightRecord.recordID.recordName, changetag: "", airplaneType: "dummy", seats: Set<ManagedSeat>())
        var recordsToSave = generateSeats(flight: flight, flightRecord: flightRecord)
        
        flightRecord["uid"] = flightRecord.recordID.recordName
        flightRecord["iataNumber"] = flight.iataNumber as CKRecordValue
        flightRecord["departureDate"] = flight.departureDate as CKRecordValue
        flightRecord["airplaneType"] = flight.airplaneType as CKRecordValue
        recordsToSave.append(flightRecord)
        user.flights = userRecord["flights"] ?? [String]()
        user.flights.append(flight.uid)
        userRecord["flights"] = user.flights as CKRecordValue
        recordsToSave.append(userRecord)
        let semaphore = DispatchSemaphore(value: 0)
        self.saveRecords(records: recordsToSave){ [unowned self] in
            self.user.changetag = self.userRecord.recordChangeTag!
            flight.changetag = flightRecord.recordChangeTag!
            let managedFlight = ManagedFlight(context: self.container.viewContext)
            managedFlight.fromFlight(flight: flight)
            self.saveContext(container: self.container)
            semaphore.signal()
        }
        semaphore.wait()
}
    
    
    func generateSeats(flight : Flight, flightRecord : CKRecord) -> [CKRecord]{
        let seatReferences = [CKRecord.Reference]()
        let seatRecords = [CKRecord]()
        flightRecord["seats"] = seatReferences
        
        return seatRecords
        
    }

        func fetchFlightsFromCloud(results : [CKRecord]){
            for result in results{
                
                let flight = Flight(departureDate: result["departureDate"]!, iataNumber: result["iataNumber"]!, uid: result["uid"]!, changetag: result.recordChangeTag!, airplaneType: result["airplaneType"]!, seats: Set<ManagedSeat>())
                
                let managedFlight = ManagedFlight(context: self.container.viewContext)
                managedFlight.fromFlight(flight: flight)
                
                var seatReferences = [CKRecord.Reference]()
                seatReferences = result["seats"] ?? [CKRecord.Reference]()
                
                if !seatReferences.isEmpty{
                    let predicate = NSPredicate(format: "ANY %@ = recordID" ,seatReferences)
                    let semaphore = DispatchSemaphore(value: 0)
                    makeCloudQuery(sortKey: "number", predicate: predicate, cloudTable: "Seat"){cloudResults in
                        for seatResult in cloudResults{
                            let seat = Seat(changetag: seatResult.recordChangeTag!, number: seatResult["number"]!, occupiedBy: seatResult["occupiedBy"]!, uid: seatResult.recordID.recordName, flight: managedFlight)
                            let managedSeat = ManagedSeat(context: self.container.viewContext)
                            managedSeat.fromSeat(seat: seat)
                        }

                        semaphore.signal()
                    }
                    semaphore.wait()
                }
         }
       saveContext(container: container)
    }
    
    func fetchFlightsFromCloudWaitForResult(results : [CKRecord], completionHandler: @escaping (Flight) -> Void){
        for result in results{
            let flight = Flight(departureDate: result["departureDate"]!, iataNumber: result["iataNumber"]!, uid: result["uid"]!, changetag: result.recordChangeTag!, airplaneType: result["airplaneType"]!, seats: Set<ManagedSeat>())
            
            let managedFlight = ManagedFlight(context: self.container.viewContext)
            managedFlight.fromFlight(flight: flight)
            
            var seatReferences = [CKRecord.Reference]()
            seatReferences = result["seats"]!
            
            if !seatReferences.isEmpty{
                let predicate = NSPredicate(format: "ANY %@ = recordName" ,seatReferences)
                
                makeCloudQuery(sortKey: "number", predicate: predicate, cloudTable: "Seat"){ [unowned self] cloudResults in
                    for seatResult in cloudResults{
                        let seat = Seat(changetag: seatResult.recordChangeTag!, number: seatResult["number"]!, occupiedBy: seatResult["occupiedBy"]!, uid: seatResult.recordID.recordName, flight: managedFlight)
                        let managedSeat = ManagedSeat(context: self.container.viewContext)
                        managedSeat.fromSeat(seat: seat)
                    }
                    completionHandler(flight)
                }
            }
        }
        
    }

    
    func compareFlightsChangeTag(localResults : [NSManagedObject],  cloudResults : [CKRecord]){
        if localResults.count == cloudResults.count{
            for i in 0...localResults.count - 1{
                let flight = localResults[i] as! ManagedFlight
                if(flight.changetag != cloudResults[i].recordChangeTag){
                    fetchFlightsFromCloud(results: [cloudResults[i]])
                }
                else{
                    compareSeats(localFlight: localResults[i], flightRecord: cloudResults[i])
                }
            }

        }
        else{
            fetchFlightsFromCloud(results: cloudResults)
        }
    }
    
    func compareFlightsChangeTagWaitForResult(localResults : [NSManagedObject],  cloudResults : [CKRecord], completionHandler: @escaping () -> Void){
        if localResults.count == cloudResults.count{
            for i in 0...localResults.count - 1{
                let flight = localResults[i] as! ManagedFlight
                if(flight.changetag != cloudResults[i].recordChangeTag){
                    fetchFlightsFromCloud(results: [cloudResults[i]])
                }
                else{
                    compareSeats(localFlight: localResults[i], flightRecord: cloudResults[i])
                }
            }
            
        }
        else{
            fetchFlightsFromCloud(results: cloudResults)
        }
        completionHandler()
    }
    
    func compareSeats(localFlight: NSManagedObject, flightRecord : CKRecord){
        let flight = localFlight as! ManagedFlight
        var localSeats = Array(flight.seats)
        localSeats.sort(by: { $0.uid > $1.uid })
        var seatReferences = [CKRecord.Reference]()
        seatReferences = flightRecord["seats"] ?? [CKRecord.Reference]()
        var recordIDs = [CKRecord.ID]()
        
        for seatReference in seatReferences{
            recordIDs.append(seatReference.recordID)
            
        }
        if !seatReferences.isEmpty{
            let cloudPred = NSPredicate(format: "ANY %@ = recordID" ,recordIDs)
            let semaphore = DispatchSemaphore(value: 0)
            makeCloudQuery(sortKey: "number", predicate: cloudPred, cloudTable: "Seat"){ [unowned self] cloudResults in
                let sortedCloudResults = cloudResults.sorted(by: { $0.recordID.recordName > $1.recordID.recordName })
                if(localSeats.count == sortedCloudResults.count && localSeats.count != 0){
                    for i in 0...sortedCloudResults.count-1{
                        if(localSeats[i].changetag != sortedCloudResults[i].recordChangeTag){
                            let seat = Seat(changetag: sortedCloudResults[i].recordChangeTag!, number: sortedCloudResults[i]["number"]!, occupiedBy: sortedCloudResults[i]["occupiedBy"]!, uid: sortedCloudResults[i].recordID.recordName, flight: flight)
                            let managedSeat = ManagedSeat(context: self.container.viewContext)
                            managedSeat.fromSeat(seat: seat)
                        }
                    }
                }
                else{
                    for seatResult in cloudResults{
                        //let seat = Seat(context: self.container.viewContext)
                        let seat = Seat(changetag: seatResult.recordChangeTag!, number: seatResult["number"]!, occupiedBy: seatResult["occupiedBy"]!, uid: seatResult.recordID.recordName, flight: flight)
                        let managedSeat = ManagedSeat(context: self.container.viewContext)
                        managedSeat.fromSeat(seat: seat)
                    }
                }
                
                semaphore.signal()
            }
            semaphore.wait()
        }
    }
    
    // has to fix: very rare case, but when flight is present in local, but not in cloud while adding a new flight, obsolate flight will be just deleted from local db, and not added. Has to analyze, but maybe flight uid introduction will fix this?
    func deleteFlightsFromLocalDb(localResults : [NSManagedObject]){
        for result in localResults{
            let managedFlight = result as! ManagedFlight
            for seat in managedFlight.seats{
                container.viewContext.delete(seat)
            }
            container.viewContext.delete(result)
            deindex(flight: managedFlight)
        }
        saveContext(container: container)

    }
    
<<<<<<< HEAD
    func unregisterFromFlightOnCloudDb(flight : ManagedFlight){
=======
    func unregisterFromFlightOnCloudDb(flight : Flight){
>>>>>>> 0aaebca8eeda9fc7aceaaba16408f7f672a5add2
        makeCloudQuery(sortKey: "uid", predicate: NSPredicate(format: "uid = %@", flight.uid), cloudTable: "Flights"){ [unowned self] cloudFlightResult in
            let result = cloudFlightResult.first!
            self.makeCloudQuery(sortKey: "number", predicate: NSPredicate(format: "flight = %@ AND occupiedBy = %@", result.recordID, self.user.email), cloudTable: "Seat"){ [unowned self] cloudSeatResults in
                let IDs = cloudSeatResults.map{$0.recordID}
                let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: IDs)
                CKContainer.default().publicCloudDatabase.add(operation)
                var seats = result["seats"]! as? [CKRecord.Reference] ?? [CKRecord.Reference]()
                seats = seats.filter{!(IDs.contains($0.recordID))}
                print (seats)
                result["seats"] = seats as CKRecordValue
                self.saveRecords(records: [self.userRecord, result]){}
                
            }
        }
    }
    func doNothing(params: [String]?){
        
    }
        
}

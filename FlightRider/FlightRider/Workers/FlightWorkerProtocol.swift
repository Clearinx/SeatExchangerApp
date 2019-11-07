//
//  FlightWorkerProtocol.swift
//  FlightRider
//
//  Created by Tomi on 2019. 11. 07..
//  Copyright © 2019. Tomi. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

protocol FlightWorkerProtocol{
    
    var databaseWorker : DatabaseWorker! { get set }
    var interactor : ListFlightsInteractor? { get set }
    
    func compareFlightsChangeTag(localResults : [NSManagedObject],  cloudResults : [CKRecord])
    func compareSeats(localFlight: NSManagedObject, flightRecord : CKRecord)
    func doNothing(params: [String]?)
    func deleteFlightsFromLocalDb(localResults : [NSManagedObject])
    func fetchFlightsFromCloud(results : [CKRecord])
    //func saveFlightDataToBothDb(params: [String]?)
}

extension FlightWorkerProtocol{
    
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
            databaseWorker.makeCloudQuery(sortKey: "number", predicate: cloudPred, cloudTable: "Seat"){ cloudResults in
                let sortedCloudResults = cloudResults.sorted(by: { $0.recordID.recordName > $1.recordID.recordName })
                if(localSeats.count == sortedCloudResults.count && localSeats.count != 0){
                    for i in 0...sortedCloudResults.count-1{
                        if(localSeats[i].changetag != sortedCloudResults[i].recordChangeTag){
                            let seat = Seat(changetag: sortedCloudResults[i].recordChangeTag!, number: sortedCloudResults[i]["number"]!, occupiedBy: sortedCloudResults[i]["occupiedBy"]!, uid: sortedCloudResults[i].recordID.recordName, flight: flight)
                            let managedSeat = ManagedSeat(context: self.databaseWorker.container.viewContext)
                            managedSeat.fromSeat(seat: seat)
                        }
                    }
                }
                else{
                    for seatResult in cloudResults{
                        //let seat = Seat(context: self.container.viewContext)
                        let seat = Seat(changetag: seatResult.recordChangeTag!, number: seatResult["number"]!, occupiedBy: seatResult["occupiedBy"]!, uid: seatResult.recordID.recordName, flight: flight)
                        let managedSeat = ManagedSeat(context: self.databaseWorker.container.viewContext)
                        managedSeat.fromSeat(seat: seat)
                    }
                }
                
                semaphore.signal()
            }
            semaphore.wait()
        }
    }
    
    func deleteFlightsFromLocalDb(localResults : [NSManagedObject]){
        for result in localResults{
            let managedFlight = result as! ManagedFlight
            for seat in managedFlight.seats{
                self.databaseWorker.container.viewContext.delete(seat)
            }
            self.databaseWorker.container.viewContext.delete(result)
            self.databaseWorker.deindex(flight: managedFlight)
        }
        self.databaseWorker.saveContext(container: self.databaseWorker.container)
        
    }
    
    func doNothing(params: [String]?){
        //saveFlightDataToBothDb(params: ["FR110"])
    }
    
    func fetchFlightsFromCloud(results : [CKRecord]){
        for result in results{
            let flight = Flight(departureDate: result["departureDate"]!, iataNumber: result["iataNumber"]!, uid: result["uid"]!, changetag: result.recordChangeTag!, airplaneType: result["airplaneType"]!, seats: Set<ManagedSeat>())
            let managedFlight = ManagedFlight(context: databaseWorker.container.viewContext)
            managedFlight.fromFlight(flight: flight)
            
            var seatReferences = [CKRecord.Reference]()
            seatReferences = result["seats"] ?? [CKRecord.Reference]()
            
            if !seatReferences.isEmpty{
                let predicate = NSPredicate(format: "ANY %@ = recordID" ,seatReferences)
                let semaphore = DispatchSemaphore(value: 0)
                self.databaseWorker.makeCloudQuery(sortKey: "number", predicate: predicate, cloudTable: "Seat"){cloudResults in
                    for seatResult in cloudResults{
                        let seat = Seat(changetag: seatResult.recordChangeTag!, number: seatResult["number"]!, occupiedBy: seatResult["occupiedBy"]!, uid: seatResult.recordID.recordName, flight: managedFlight)
                        let managedSeat = ManagedSeat(context: self.databaseWorker.container.viewContext)
                        managedSeat.fromSeat(seat: seat)
                    }
                    
                    semaphore.signal()
                }
                semaphore.wait()
            }
        }
        self.databaseWorker.saveContext(container: self.databaseWorker.container)
    }
    
    func saveFlightDataToBothDbDummy(params: [String]?){
        
        let flightRecord = CKRecord(recordType: "Flights")
        
        //let departureDate = params![1]
        let dateFormat = Date()//getDate(receivedDate: departureDate)
        var flight = Flight(departureDate: dateFormat, iataNumber: params![0], uid: flightRecord.recordID.recordName, changetag: "", airplaneType: "dummy", seats: Set<ManagedSeat>())
        var recordsToSave = [CKRecord]()//generateSeats(flight: flight, flightRecord: flightRecord)
        
        flightRecord["uid"] = flightRecord.recordID.recordName
        flightRecord["iataNumber"] = flight.iataNumber as CKRecordValue
        flightRecord["departureDate"] = flight.departureDate as CKRecordValue
        flightRecord["airplaneType"] = flight.airplaneType as CKRecordValue
        recordsToSave.append(flightRecord)
        var flights = interactor?.dataStore.cloudUser.userRecord["flights"] as! [String]
        flights.append(flight.uid)
        interactor?.dataStore.cloudUser.userRecord["flights"] = flights as CKRecordValue
        recordsToSave.append((interactor?.dataStore.cloudUser.userRecord)!)
        //user.flights = userRecord["flights"] ?? [String]()
        //user.flights.append(flight.uid)
        //userRecord["flights"] = user.flights as CKRecordValue
        //recordsToSave.append(userRecord)
        //let semaphore = DispatchSemaphore(value: 0)
        self.databaseWorker.saveRecords(records: recordsToSave){
            print("finished")
            //self.user.changetag = self.userRecord.recordChangeTag!
            //flight.changetag = flightRecord.recordChangeTag!
            //let managedFlight = ManagedFlight(context: self.databaseWorker.container.viewContext)
            //managedFlight.fromFlight(flight: flight)
            //self.databaseWorker.saveContext(container: self.databaseWorker.container)
            //semaphore.signal()
        }
        //semaphore.wait()
    }
}

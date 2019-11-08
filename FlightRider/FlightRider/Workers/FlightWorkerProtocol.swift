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
    func saveFlightDataToBothDb(params: [String]?)
    func saveFlightDataToBothDbAppendToFlightList(params: [String]?)
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
    
    func compareFlightsChangeTagAndAppendToUserList(localResults : [NSManagedObject],  cloudResults : [CKRecord]){
        compareFlightsChangeTagWaitForResult(localResults: localResults, cloudResults: cloudResults){
            let localFlight = localResults.first! as! ManagedFlight
            let request = ListFlights.FlightAddition.PushFlightToDataStore(flight: localFlight)
            self.interactor?.pushFetchedFlightFromCloudToDatastore(request: request)
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
    
    func createStringsFromJson(json : JSON, flightCode : String, departureDate : String) -> [String]{
        var result = [String]()
        result.append(flightCode)
        let departureDateAndTime = "\(departureDate)  \(json["departureTime"].stringValue)"
        result.append(departureDateAndTime)
        return result
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
    
    func fetchFlightsFromCloudWaitForResult(results : [CKRecord], completionHandler: @escaping (ManagedFlight) -> Void){
        for result in results{
            let flight = Flight(departureDate: result["departureDate"]!, iataNumber: result["iataNumber"]!, uid: result["uid"]!, changetag: result.recordChangeTag!, airplaneType: result["airplaneType"]!, seats: Set<ManagedSeat>())
            
            let managedFlight = ManagedFlight(context: self.databaseWorker.container.viewContext)
            managedFlight.fromFlight(flight: flight)
            
            var seatReferences : [CKRecord.Reference]
            seatReferences = result["seats"] ?? [CKRecord.Reference]()
            
            if !seatReferences.isEmpty{
                let predicate = NSPredicate(format: "ANY %@ = recordName" ,seatReferences)
                let semaphore = DispatchSemaphore(value: 0)
                self.databaseWorker.makeCloudQuery(sortKey: "number", predicate: predicate, cloudTable: "Seat"){ cloudResults in
                    for seatResult in cloudResults{
                        let seat = Seat(changetag: seatResult.recordChangeTag!, number: seatResult["number"]!, occupiedBy: seatResult["occupiedBy"]!, uid: seatResult.recordID.recordName, flight: managedFlight)
                        let managedSeat = ManagedSeat(context: self.databaseWorker.container.viewContext)
                        managedSeat.fromSeat(seat: seat)
                    }
                    semaphore.signal()
                }
                semaphore.wait()
            }
            completionHandler(managedFlight)
        }
        
    }
    
    func fetchFlightsFromCloudAndAppendToUserList(results : [CKRecord]){
        fetchFlightsFromCloudWaitForResult(results: results){ flight in
            let request = ListFlights.FlightAddition.PushFlightToDataStore(flight: flight)
            self.interactor?.pushFetchedFlightFromCloudToDatastore(request: request)
        }
    }
    
    func saveFlightDataToBothDb(params: [String]?){
        let departureDate = params![1]
        let dateFormat = getDate(receivedDate: departureDate)
        /*let cloudFlight = CloudFlight(airplaneType: "dummy", departureDate: dateFormat, iataNumber: params![0], seats: [CKRecord.Reference]())*/
        let flightRecord = CKRecord(recordType: "Flights")
        flightRecord["uid"] = flightRecord.recordID.recordName
        flightRecord["iataNumber"] = params![0] as CKRecordValue
        flightRecord["departureDate"] = dateFormat as CKRecordValue
        flightRecord["airplaneType"] = "dummy" as CKRecordValue
        let semaphore = DispatchSemaphore(value: 0)
        self.databaseWorker.saveRecords(records: [flightRecord]/*[cloudFlight.flightRecord]*/){
            let flight = Flight(departureDate: dateFormat, iataNumber: params![0], uid: flightRecord.recordID.recordName, changetag: flightRecord.recordChangeTag!, airplaneType: "dummy", seats: Set<ManagedSeat>())
            let managedFlight = ManagedFlight(context: self.databaseWorker.container.viewContext)
            managedFlight.fromFlight(flight: flight)
            let request = ListFlights.FlightAddition.PushFlightToDataStore(flight: managedFlight)
            self.interactor?.pushFetchedFlightFromCloudToDatastore(request: request)
            semaphore.signal()
        }
        semaphore.wait()
        //var recordsToSave = [CKRecord]()
        /*flightRecord["uid"] = flightRecord.recordID.recordName
        flightRecord["iataNumber"] = flight.iataNumber as CKRecordValue
        flightRecord["departureDate"] = flight.departureDate as CKRecordValue
        flightRecord["airplaneType"] = flight.airplaneType as CKRecordValue
        flightRecord["seats"] = [CKRecord.Reference]()*/
        //let model = ListFlights.FlightAddition.PushCreatedFlightToDataStore(localFlight: managedFlight, cloudFlight: cloudFlight)
        //interactor?.pushCreatedFlightToDatastore(model: model)
        /*recordsToSave.append(flightRecord)
        user.flights = userRecord["flights"] ?? [String]()
        user.flights.append(flight.uid)
        userRecord["flights"] = user.flights as CKRecordValue
        recordsToSave.append(userRecord)
        let semaphore = DispatchSemaphore(value: 0)
        self.databaseWorker.saveRecords(records: recordsToSave){
            self.user.changetag = self.userRecord.recordChangeTag!
            flight.changetag = flightRecord.recordChangeTag!
            //let managedFlight = ManagedFlight(context: self.databaseWorker.container.viewContext)
            //managedFlight.fromFlight(flight: flight)
            self.databaseWorker.saveContext(container: self.databaseWorker.container)
            semaphore.signal()
        }
        semaphore.wait()*/
    }
    
    func saveFlightDataToBothDbAppendToFlightList(params: [String]?){
        let flightCode = params![0]
        let departureDate = params![1]
        let airlineIata = flightCode.prefix(2)
        let flightNumber = flightCode.suffix(flightCode.count-2)
        let results = [flightCode, "\(departureDate)  11:20:00"]
         saveFlightDataToBothDb(params: results)
        /*let urlString = "https://aviation-edge.com/v2/public/routes?key=ee252d-c24759&airlineIata=\(airlineIata)&flightNumber=\(flightNumber)"
        do{
            let data = try String(contentsOf: URL(string: urlString)!)
            let jsonData = JSON(parseJSON: data)
            let jsonArray = jsonData.arrayValue
            if (!(jsonArray.isEmpty)){
                let results = self.createStringsFromJson(json : jsonArray[0], flightCode: flightCode, departureDate: departureDate)
                saveFlightDataToBothDb(params: results)
                
            }
            else{
                let response = ListFlights.FlightAddition.Response(errorMessage: "Flight not found")
                interactor?.fetchFlightAdditionResponse(response: response)
            }
            
        }
        catch{
            let response = ListFlights.FlightAddition.Response(errorMessage: "Flight not found")
            interactor?.fetchFlightAdditionResponse(response: response)
            
        }*/
    }
    
    func getDate(receivedDate : String) -> Date
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let date = formatter.date(from: receivedDate) ?? Date()
        return date
    }
    
    /*func saveFlightDataToBothDbDummy(params: [String]?){
        
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
    }*/
}
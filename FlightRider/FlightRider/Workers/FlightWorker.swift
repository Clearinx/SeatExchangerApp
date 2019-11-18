//
//  FlightWorker.swift
//  FlightRider
//
//  Created by Tomi on 2019. 08. 30..
//  Copyright © 2019. Tomi. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

protocol FlightWorkerProtocol: class {

    var databaseWorker: DatabaseWorkerProtocol! { get set }
    var user: ManagedUser! { get set }
    var userRecord: CKRecord { get set }

    func saveFlightDataToBothDb(params: [String]?)
    func generateSeats(flight: Flight, flightRecord: CKRecord) -> [CKRecord]
    func fetchFlightsFromCloud(results: [CKRecord])
    func fetchFlightsFromCloudWaitForResult(results: [CKRecord], completionHandler: @escaping (Flight) -> Void)
    func compareFlightsChangeTag(localResults: [NSManagedObject], cloudResults: [CKRecord])
    func compareFlightsChangeTagWaitForResult(localResults: [NSManagedObject], cloudResults: [CKRecord], completionHandler: @escaping () -> Void)
    func getDate(receivedDate: String) -> Date
    func compareSeats(localFlight: NSManagedObject, flightRecord: CKRecord)
    func deleteFlightsFromLocalDb(localResults: [NSManagedObject])
    func doNothing(params: [String]?)
    func saveFlightDataToBothDbAppendToFlightList(params: [String]?)
    func fetchFlightsFromCloudAndAppendToUserList(results: [CKRecord])
    func compareFlightsChangeTagAndAppendToUserList(localResults: [NSManagedObject], cloudResults: [CKRecord])

}

extension FlightWorkerProtocol {

    func saveFlightDataToBothDb(params: [String]?) {

        let flightRecord = CKRecord(recordType: "Flights")

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
        self.databaseWorker.saveRecords(records: recordsToSave) { [unowned self] in
            self.user.changetag = self.userRecord.recordChangeTag ?? ""
            flight.changetag = flightRecord.recordChangeTag ?? ""
            let managedFlight = ManagedFlight(context: self.databaseWorker.container.viewContext)
            managedFlight.fromFlight(flight: flight)
            self.databaseWorker.saveContext(container: self.databaseWorker.container)
            semaphore.signal()
        }
        semaphore.wait()
    }

    func generateSeats(flight: Flight, flightRecord: CKRecord) -> [CKRecord] {
        let seatReferences = [CKRecord.Reference]()
        let seatRecords = [CKRecord]()
        flightRecord["seats"] = seatReferences

        return seatRecords

    }

    func fetchFlightsFromCloud(results: [CKRecord]) {
        for result in results {

            let flight = Flight(departureDate: result["departureDate"]!, iataNumber: result["iataNumber"]!, uid: result["uid"]!, changetag: result.recordChangeTag ?? "", airplaneType: result["airplaneType"]!, seats: Set<ManagedSeat>())

            let managedFlight = ManagedFlight(context: self.databaseWorker.container.viewContext)
            managedFlight.fromFlight(flight: flight)

            var seatReferences = [CKRecord.Reference]()
            seatReferences = result["seats"] ?? [CKRecord.Reference]()

            if !seatReferences.isEmpty {
                let predicate = NSPredicate(format: "ANY %@ = recordID", seatReferences)
                let semaphore = DispatchSemaphore(value: 0)
                self.databaseWorker.makeCloudQuery(sortKey: "number", predicate: predicate, cloudTable: "Seat") {cloudResults in
                    for seatResult in cloudResults {
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

    func fetchFlightsFromCloudWaitForResult(results: [CKRecord], completionHandler: @escaping (Flight) -> Void) {
        for result in results {
            let flight = Flight(departureDate: result["departureDate"]!, iataNumber: result["iataNumber"]!, uid: result["uid"]!, changetag: result.recordChangeTag!, airplaneType: result["airplaneType"]!, seats: Set<ManagedSeat>())

            let managedFlight = ManagedFlight(context: self.databaseWorker.container.viewContext)
            managedFlight.fromFlight(flight: flight)

            var seatReferences = [CKRecord.Reference]()
            seatReferences = result["seats"]!

            if !seatReferences.isEmpty {
                let predicate = NSPredicate(format: "ANY %@ = recordName", seatReferences)

                self.databaseWorker.makeCloudQuery(sortKey: "number", predicate: predicate, cloudTable: "Seat") { [unowned self] cloudResults in
                    for seatResult in cloudResults {
                        let seat = Seat(changetag: seatResult.recordChangeTag!, number: seatResult["number"]!, occupiedBy: seatResult["occupiedBy"]!, uid: seatResult.recordID.recordName, flight: managedFlight)
                        let managedSeat = ManagedSeat(context: self.databaseWorker.container.viewContext)
                        managedSeat.fromSeat(seat: seat)
                    }

                }
            }
            completionHandler(flight)
        }

    }

    func compareFlightsChangeTag(localResults: [NSManagedObject], cloudResults: [CKRecord]) {
        if localResults.count == cloudResults.count {
            for i in 0...localResults.count - 1 {
                let flight = localResults[i] as! ManagedFlight
                if(flight.changetag != cloudResults[i].recordChangeTag ?? "") {
                    fetchFlightsFromCloud(results: [cloudResults[i]])
                } else {
                    compareSeats(localFlight: localResults[i], flightRecord: cloudResults[i])
                }
            }

        } else {
            fetchFlightsFromCloud(results: cloudResults)
        }
    }

    func compareFlightsChangeTagWaitForResult(localResults: [NSManagedObject], cloudResults: [CKRecord], completionHandler: @escaping () -> Void) {
        if localResults.count == cloudResults.count {
            for i in 0...localResults.count - 1 {
                let flight = localResults[i] as! ManagedFlight
                if(flight.changetag != cloudResults[i].recordChangeTag) {
                    fetchFlightsFromCloud(results: [cloudResults[i]])
                } else {
                    compareSeats(localFlight: localResults[i], flightRecord: cloudResults[i])
                }
            }

        } else {
            fetchFlightsFromCloud(results: cloudResults)
        }
        completionHandler()
    }

    func getDate(receivedDate: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let date = formatter.date(from: receivedDate) ?? Date()
        return date
    }

    func compareSeats(localFlight: NSManagedObject, flightRecord: CKRecord) {
        let flight = localFlight as! ManagedFlight
        var localSeats = Array(flight.seats)
        localSeats.sort(by: { $0.uid > $1.uid })
        var seatReferences = [CKRecord.Reference]()
        seatReferences = flightRecord["seats"] ?? [CKRecord.Reference]()
        var recordIDs = [CKRecord.ID]()

        for seatReference in seatReferences {
            recordIDs.append(seatReference.recordID)

        }
        if !seatReferences.isEmpty {
            let cloudPred = NSPredicate(format: "ANY %@ = recordID", recordIDs)
            let semaphore = DispatchSemaphore(value: 0)
            self.databaseWorker.makeCloudQuery(sortKey: "number", predicate: cloudPred, cloudTable: "Seat") { [unowned self] cloudResults in
                let sortedCloudResults = cloudResults.sorted(by: { $0.recordID.recordName > $1.recordID.recordName })
                if(localSeats.count == sortedCloudResults.count && localSeats.count != 0) {
                    for i in 0...sortedCloudResults.count-1 {
                        if(localSeats[i].changetag != sortedCloudResults[i].recordChangeTag) {
                            let seat = Seat(changetag: sortedCloudResults[i].recordChangeTag!, number: sortedCloudResults[i]["number"]!, occupiedBy: sortedCloudResults[i]["occupiedBy"]!, uid: sortedCloudResults[i].recordID.recordName, flight: flight)
                            let managedSeat = ManagedSeat(context: self.databaseWorker.container.viewContext)
                            managedSeat.fromSeat(seat: seat)
                        }
                    }
                } else {
                    for seatResult in cloudResults {
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

    // has to fix: very rare case, but when flight is present in local, but not in cloud while adding a new flight, obsolate flight will be just deleted from local db, and not added. Has to analyze, but maybe flight uid introduction will fix this?
    func deleteFlightsFromLocalDb(localResults: [NSManagedObject]) {
        for result in localResults {
            let managedFlight = result as! ManagedFlight
            for seat in managedFlight.seats {
                self.databaseWorker.container.viewContext.delete(seat)
            }
            self.databaseWorker.container.viewContext.delete(result)
            self.databaseWorker.deindex(flight: managedFlight)
        }
        self.databaseWorker.saveContext(container: self.databaseWorker.container)

    }

    func unregisterFromFlightOnCloudDb(flight: ManagedFlight) {
        self.databaseWorker.makeCloudQuery(sortKey: "uid", predicate: NSPredicate(format: "uid = %@", flight.uid), cloudTable: "Flights") { [unowned self] cloudFlightResult in
            if let result = cloudFlightResult.first {
                self.databaseWorker.makeCloudQuery(sortKey: "number", predicate: NSPredicate(format: "flight = %@ AND occupiedBy = %@", result.recordID, self.user.email), cloudTable: "Seat") { [unowned self] cloudSeatResults in
                    let IDs = cloudSeatResults.map {$0.recordID}
                    let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: IDs)
                    CKContainer.default().publicCloudDatabase.add(operation)
                    var seats = result["seats"] as? [CKRecord.Reference] ?? [CKRecord.Reference]()
                    seats = seats.filter {!(IDs.contains($0.recordID))}
                    result["seats"] = seats as CKRecordValue
                    self.databaseWorker.saveRecords(records: [self.userRecord, result]) {}

                }
            } else {
                print("Flight not found")
            }
        }
    }
    func doNothing(params: [String]?) {

    }

    func saveFlightDataToBothDbAppendToFlightList(params: [String]?) { //flight validity check disabled for testing
        let flightCode = params![0]
        let departureDate = params![1]
        let results = [flightCode, "\(departureDate)  11:20:00"]
        saveFlightDataToBothDb(params: results)
        /*let airlineIata = flightCode.prefix(2)
         let flightNumber = flightCode.suffix(flightCode.count-2)
         let urlString = "https://aviation-edge.com/v2/public/routes?key=ee252d-c24759&airlineIata=\(airlineIata)&flightNumber=\(flightNumber)"
         do{
         let data = try String(contentsOf: URL(string: urlString)!)
         let jsonData = JSON(parseJSON: data)
         let jsonArray = jsonData.arrayValue
         if (!(jsonArray.isEmpty)){
         let results = self.createStringsFromJson(json : jsonArray[0], flightCode: flightCode, departureDate: departureDate)
         saveFlightDataToBothDb(params: results)
         
         }
         else{
         flightNotFoundError()
         }
         
         }
         catch{
         flightNotFoundError()
         
         }*/
    }

    func fetchFlightsFromCloudAndAppendToUserList(results: [CKRecord]) {
        fetchFlightsFromCloudWaitForResult(results: results) { flight in
            self.user.flights = self.userRecord["flights"]!
            self.user.flights.append(flight.uid)
            self.userRecord["flights"] = self.user.flights as CKRecordValue
            self.databaseWorker.saveRecords(records: [self.userRecord]) { [unowned self] in
                self.user.changetag = self.userRecord.recordChangeTag!
                self.databaseWorker.saveContext(container: self.databaseWorker.container)
            }
        }
    }

    func compareFlightsChangeTagAndAppendToUserList(localResults: [NSManagedObject], cloudResults: [CKRecord]) {
        compareFlightsChangeTagWaitForResult(localResults: localResults, cloudResults: cloudResults) {
            self.user.flights = self.userRecord["flights"]!
            self.user.flights.append(cloudResults.first!["uid"]!)
            self.userRecord["flights"] = self.user.flights as CKRecordValue
            self.databaseWorker.saveRecords(records: [self.userRecord]) { [unowned self] in
                self.user.changetag = self.userRecord.recordChangeTag!
                self.databaseWorker.saveContext(container: self.databaseWorker.container)
            }
        }
    }

}

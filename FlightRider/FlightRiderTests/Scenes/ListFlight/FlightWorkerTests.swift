//
//  FlightWorkerTests.swift
//  FlightRiderTests
//
//  Created by Tomi on 2019. 11. 13..
//  Copyright © 2019. Tomi. All rights reserved.
//

@testable import FlightRider
import UIKit
import XCTest
import CoreData
import CloudKit

class FlightWorkerTests: XCTestCase {
    // MARK: - Subject under test

    var sut: ListFlightsViewController!
    //var context : NSManagedObjectContext!

    // MARK: - Test lifecycle

    override func setUp() {
        super.setUp()
        setupListFlightsViewController()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Test setup

    func setupListFlightsViewController() {
        sut = ListFlightsViewController(nibName: "FlightList", bundle: Bundle.main)
    }

    class DatabaseWorkerSpy: DatabaseWorkerProtocol {
        var container: NSPersistentContainer!

        var syncLocalDBWithiCloudCalled = false
        var deindexCalled = false
        var indexCalled = false
        var makeCloudQueryCalled = false
        var saveRecordsCalled = false
        var setupContainerCalled = false
        var makeLocalQueryCalled = false
        var saveContextCalled = false
        var getLocalDatabaseCalled = false

        var recordsSaved: [CKRecord]!
        var localUser: ManagedUser!

        var uid: String?
        var found: Bool!

        init() {
            container = NSPersistentContainer(name: "FlightRider")
            container.loadPersistentStores { _, error in
                self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

                if let error = error {
                    print("Unresolved error \(error)")
                }

            }
        }

        func syncLocalDBWithiCloud(providedObject: NSManagedObject.Type, sortKey: String, sortValue: [String], cloudTable: String, saveParams: [String]?, container: NSPersistentContainer, delegate: NSFetchedResultsControllerDelegate, saveToBothDbHandler: @escaping SelectSeatsWorkerTests.DatabaseWorkerSpy.StringValuesParameter, fetchFromCloudHandler: @escaping SelectSeatsWorkerTests.DatabaseWorkerSpy.CKRecordParameter, compareChangeTagHandler: @escaping SelectSeatsWorkerTests.DatabaseWorkerSpy.NSManagedAndCkrecordParameter, decideIfUpdateCloudOrDeleteHandler: @escaping SelectSeatsWorkerTests.DatabaseWorkerSpy.NSManagedObjectParameter, completionHandler: @escaping () -> Void) {

            syncLocalDBWithiCloudCalled = true
        }

        func deindex(flight: ManagedFlight) {
            deindexCalled = true
        }

        func index(flight: ManagedFlight) {
            indexCalled = true
        }

        func makeCloudQuery(sortKey: String, predicate: NSPredicate, cloudTable: String, completionHandler: @escaping ([CKRecord]) -> Void) {
            makeCloudQueryCalled = true
            let flightRecord = injectCKRecord(found: found, uid: uid, sortKey: sortKey)
            completionHandler(flightRecord)
        }

        func injectCKRecord(found: Bool, uid: String?, sortKey: String) -> [CKRecord] {
            if found {
                if(sortKey == "uid") {
                    let flightRecord = CKRecord(recordType: "Flight")
                    flightRecord["departureDate"] = "2019-05-18"
                    flightRecord["iataNumber"] = "DummyIata"
                    flightRecord["uid"] = "DummyUid"
                    flightRecord["airplaneType"] = "dummy"
                    return [flightRecord]
                } else {
                    let seatRecord = CKRecord(recordType: "Seat")
                    seatRecord["number"] = "01A"
                    seatRecord["occupiedBy"] = "Dummy"
                    seatRecord["flight"] = nil
                    return [seatRecord]
                }
            } else {
                return [CKRecord]()
            }

        }

        func saveRecords(records: [CKRecord], completionHandler: @escaping () -> Void) {
            saveRecordsCalled = true
            recordsSaved = records
            completionHandler()
        }

        func setupContainer() {
            setupContainerCalled = true
        }

        func makeLocalQuery(sortKey: String, predicate: NSPredicate, request: NSFetchRequest<NSManagedObject>, container: NSPersistentContainer, delegate: NSFetchedResultsControllerDelegate) -> [NSManagedObject]? {
            makeLocalQueryCalled = true
            return [NSManagedObject]()
        }

        func saveContext(container: NSPersistentContainer) {
            saveContextCalled = true
        }

        func getUserFromLocalDatabase(sortkey: String, sortvalue: String) {

        }

        func getLocalDatabase(container: NSPersistentContainer, delegate: NSFetchedResultsControllerDelegate) {
            getLocalDatabaseCalled = true
        }
    }

    // MARK: - Test doubles

    func testSaveFlightDataToBothDb() {
        // Given
        let databaseWorkerSpy = DatabaseWorkerSpy()
        sut.databaseWorker = databaseWorkerSpy

        //When
        sut.userRecord = CKRecord(recordType: "Dummy")
        sut.userRecord["uid"] = "DummyUid"
        sut.userRecord["email"] = "DummyEmail"
        sut.userRecord["flights"] = [CKRecord.Reference]()

        let user = User(email: "DummyEmail", flights: [String](), uid: "DummyUid", changetag: "NotDummy")
        sut.user = ManagedUser(context: databaseWorkerSpy.container.viewContext)
        sut.user.fromUser(user: user)

        let params = ["DummyIataNumber", "2019-05-18"]
        sut.saveFlightDataToBothDb(params: params)

        //Then
        XCTAssert(databaseWorkerSpy.saveContextCalled == true)
        XCTAssert(databaseWorkerSpy.recordsSaved[0]["iataNumber"] == "DummyIataNumber")
        XCTAssert((databaseWorkerSpy.recordsSaved[1]["flights"] as! [String]).count  == 1)
    }

    func testCompareFlightsChangeTag() {
        // Given
        let databaseWorkerSpy = DatabaseWorkerSpy()
        sut.databaseWorker = databaseWorkerSpy

        //When
        let flightRecord = CKRecord(recordType: "Flight")
        flightRecord["departureDate"] = "2019-05-18"
        flightRecord["iataNumber"] = "DummyIata"
        flightRecord["uid"] = "DummyUid"
        flightRecord["airplaneType"] = "dummy"

        let flight = Flight(departureDate: Date(), iataNumber: "DummyIata", uid: "DummyUid", changetag: "", airplaneType: "dummy", seats: Set<ManagedSeat>())
        let managedFlight = ManagedFlight(context: databaseWorkerSpy.container.viewContext)
        managedFlight.fromFlight(flight: flight)

        sut.compareFlightsChangeTag(localResults: [managedFlight], cloudResults: [flightRecord])

        //Then
        XCTAssert(databaseWorkerSpy.saveRecordsCalled == false)
        XCTAssert(databaseWorkerSpy.saveContextCalled == false)
    }

    func testCompareFlightsChangeTagDifferent() {
        // Given
        let databaseWorkerSpy = DatabaseWorkerSpy()
        sut.databaseWorker = databaseWorkerSpy

        //When
        let flightRecord = CKRecord(recordType: "Flight")
        flightRecord["departureDate"] = sut.getDate(receivedDate: "2019-08-15") as CKRecordValue
        flightRecord["iataNumber"] = "DummyIata" as CKRecordValue
        flightRecord["uid"] = "DummyUid" as CKRecordValue
        flightRecord["airplaneType"] = "dummy" as CKRecordValue

        let flight = Flight(departureDate: Date(), iataNumber: "DummyIata", uid: "DummyUid", changetag: "NotDummy", airplaneType: "dummy", seats: Set<ManagedSeat>())
        let managedFlight = ManagedFlight(context: databaseWorkerSpy.container.viewContext)
        managedFlight.fromFlight(flight: flight)

        sut.compareFlightsChangeTag(localResults: [managedFlight], cloudResults: [flightRecord])

        //Then
        XCTAssert(databaseWorkerSpy.saveRecordsCalled == false)
        XCTAssert(databaseWorkerSpy.saveContextCalled == true)
    }

    func testUnregisterFromFlightOnCloudDb() {
        // Given
        let databaseWorkerSpy = DatabaseWorkerSpy()
        sut.databaseWorker = databaseWorkerSpy

        //Then
        let flight = Flight(departureDate: Date(), iataNumber: "DummyIata", uid: "DummyUid", changetag: "NotDummy", airplaneType: "dummy", seats: Set<ManagedSeat>())
        let managedFlight = ManagedFlight(context: databaseWorkerSpy.container.viewContext)
        managedFlight.fromFlight(flight: flight)
        sut.user = ManagedUser(context: databaseWorkerSpy.container.viewContext)
        sut.user.email = "DummyEmail"
        databaseWorkerSpy.found = true

        sut.unregisterFromFlightOnCloudDb(flight: managedFlight)

        //When
        XCTAssert(databaseWorkerSpy.saveRecordsCalled == true)
    }

    func testUnregisterFromFlightOnCloudDbNotFound() {
        // Given
        let databaseWorkerSpy = DatabaseWorkerSpy()
        sut.databaseWorker = databaseWorkerSpy

        //Then
        let flight = Flight(departureDate: Date(), iataNumber: "DummyIata", uid: "DummyUid", changetag: "NotDummy", airplaneType: "dummy", seats: Set<ManagedSeat>())
        let managedFlight = ManagedFlight(context: databaseWorkerSpy.container.viewContext)
        managedFlight.fromFlight(flight: flight)
        sut.user = ManagedUser(context: databaseWorkerSpy.container.viewContext)
        sut.user.email = "DummyEmail"
        databaseWorkerSpy.found = false

        sut.unregisterFromFlightOnCloudDb(flight: managedFlight)

        //When
        XCTAssert(databaseWorkerSpy.saveRecordsCalled == false)
    }
}

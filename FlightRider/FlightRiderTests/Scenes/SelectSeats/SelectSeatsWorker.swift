//
//  SelectSeatsWorker.swift
//  FlightRiderTests
//
//  Created by Tamas Attila Horvath on 2019. 11. 12..
//  Copyright © 2019. Tomi. All rights reserved.
//

@testable import FlightRider
import UIKit
import XCTest
import CoreData
import CloudKit

class SelectSeatsWorkerTests: XCTestCase {
    // MARK: - Subject under test

    var sut: SelectSeatsWorker!
    //var context : NSManagedObjectContext!

    // MARK: - Test lifecycle

    override func setUp() {
        super.setUp()
        setupSelectSeatsWorker()
        //context = setUpInMemoryManagedObjectContext()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Test setup

    func setupSelectSeatsWorker() {
        sut = SelectSeatsWorker()
    }

    // MARK: - Test doubles

    class SelectSeatsBusinessLogicSpy: SelectSeatsBusinessLogic {
        var requestCheckSeatsDataCalled = false
        var requestDisplayDataCalled = false
        var requestUpdateSeatCalled = false
        var requestPickerInitializationCalled = false
        var fetchPickerDataSourceCalled = false
        var fetchUpdateSeatResultCalled = false
        var pushDataFromPreviousViewControllerCalled = false
        var pushJustSelectedSeatStateCalled = false

        var seatResultResponse: SelectSeats.UpdateSeat.Response!

        func requestCheckSeatsData(request: SelectSeats.StoredData.Request) {
            requestCheckSeatsDataCalled = true
        }

        func requestDisplayData(request: SelectSeats.DisplayData.Request) {
            requestDisplayDataCalled = true
        }

        func requestUpdateSeat(request: SelectSeats.UpdateSeat.Request) {
            requestUpdateSeatCalled = true
        }

        func requestPickerInitialization(request: SelectSeats.PickerDataSource.Request) {
            requestPickerInitializationCalled = true
        }

        func fetchPickerDataSource(response: SelectSeats.PickerDataSource.Response) {
            fetchPickerDataSourceCalled = true
        }

        func fetchUpdateSeatResult(response: SelectSeats.UpdateSeat.Response) {
            fetchUpdateSeatResultCalled = true
            seatResultResponse = response
        }

        func pushDataFromPreviousViewController(viewModel: ListFlights.SelectSeatsData.ViewModel) {
            pushDataFromPreviousViewControllerCalled = true
        }

        func pushJustSelectedSeatState(request: SelectSeats.StoredData.Request) {
            pushJustSelectedSeatStateCalled = true
        }
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

        var uid: String?
        var found: Bool!

        init() {
            container = NSPersistentContainer(name: "Dummy")
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
            let flightRecord = injectCKRecord(found: found, uid: uid)
            completionHandler(flightRecord)
        }

        func injectCKRecord(found: Bool, uid: String?) -> [CKRecord] {
            if found {
                let flightRecord = CKRecord(recordType: "Flight")
                if let uid = uid {
                    flightRecord["uid"] = uid
                }
                return [flightRecord]
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

        func getLocalDatabase(container: NSPersistentContainer, delegate: NSFetchedResultsControllerDelegate) {
            getLocalDatabaseCalled = true
        }
    }

    func testRequestUpdateSeat() {
        // Given
        let selectSeatsBusinessLogicSpy = SelectSeatsBusinessLogicSpy()
        let dataBaseWorkerSpy = DatabaseWorkerSpy()
        sut.interactor = selectSeatsBusinessLogicSpy
        sut.databaseWorker = dataBaseWorkerSpy

        // When
        let flight = ManagedFlight(context: dataBaseWorkerSpy.container.viewContext)
        flight.seats = Set<ManagedSeat>()

        dataBaseWorkerSpy.found = true

        let request = SelectSeats.UpdateSeat.Request(selectedSeatNumber: "01A", email: "dummy", flight: flight)
        sut.requestUpdateSeat(request: request)

        // Then
        XCTAssert(selectSeatsBusinessLogicSpy.seatResultResponse.errorMessage == nil)
        XCTAssert(selectSeatsBusinessLogicSpy.seatResultResponse.selectedSeatNumber == "01A")
        XCTAssert(selectSeatsBusinessLogicSpy.seatResultResponse.result == true)
    }

    func testRequestUpdateSeatNoCloudResult() {
        // Given
        let selectSeatsBusinessLogicSpy = SelectSeatsBusinessLogicSpy()
        let dataBaseWorkerSpy = DatabaseWorkerSpy()
        sut.interactor = selectSeatsBusinessLogicSpy
        sut.databaseWorker = dataBaseWorkerSpy

        // When
        let flight = ManagedFlight(context: dataBaseWorkerSpy.container.viewContext)
        flight.seats = Set<ManagedSeat>()

        dataBaseWorkerSpy.found = false

        let request = SelectSeats.UpdateSeat.Request(selectedSeatNumber: "01A", email: "dummy", flight: flight)
        sut.requestUpdateSeat(request: request)

        // Then
        XCTAssert(selectSeatsBusinessLogicSpy.seatResultResponse.errorMessage == "Could not find flight")
        XCTAssert(selectSeatsBusinessLogicSpy.seatResultResponse.selectedSeatNumber == nil)
        XCTAssert(selectSeatsBusinessLogicSpy.seatResultResponse.result == false)
    }

    func testRequestUpdateSeatNumberNil() {
        // Given
        let selectSeatsBusinessLogicSpy = SelectSeatsBusinessLogicSpy()
        let dataBaseWorkerSpy = DatabaseWorkerSpy()
        sut.interactor = selectSeatsBusinessLogicSpy
        sut.databaseWorker = dataBaseWorkerSpy

        // When
        let flight = ManagedFlight(context: dataBaseWorkerSpy.container.viewContext)
        flight.seats = Set<ManagedSeat>()

        dataBaseWorkerSpy.found = false

        let request = SelectSeats.UpdateSeat.Request(selectedSeatNumber: nil, email: "dummy", flight: flight)
        sut.requestUpdateSeat(request: request)

        // Then
        XCTAssert(selectSeatsBusinessLogicSpy.seatResultResponse.errorMessage == "Some input is missing")
        XCTAssert(selectSeatsBusinessLogicSpy.seatResultResponse.selectedSeatNumber == nil)
        XCTAssert(selectSeatsBusinessLogicSpy.seatResultResponse.result == false)
    }

    func testRequestUpdateSeatInvalidSeat() {
        // Given
        let selectSeatsBusinessLogicSpy = SelectSeatsBusinessLogicSpy()
        let dataBaseWorkerSpy = DatabaseWorkerSpy()
        sut.interactor = selectSeatsBusinessLogicSpy
        sut.databaseWorker = dataBaseWorkerSpy

        // When
        let flight = ManagedFlight(context: dataBaseWorkerSpy.container.viewContext)

        dataBaseWorkerSpy.found = true

        let request = SelectSeats.UpdateSeat.Request(selectedSeatNumber: "XXX", email: "dummy", flight: flight)
        sut.requestUpdateSeat(request: request)

        // Then
        XCTAssert(selectSeatsBusinessLogicSpy.seatResultResponse.errorMessage == nil)
        XCTAssert(selectSeatsBusinessLogicSpy.seatResultResponse.selectedSeatNumber == "XXX")
        XCTAssert(selectSeatsBusinessLogicSpy.seatResultResponse.result == true)
    }
}

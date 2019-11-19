//
//  SelectSeatsInteractorTests.swift
//  FlightRiderTests
//
//  Created by Tomi on 2019. 11. 12..
//  Copyright © 2019. Tomi. All rights reserved.
//

@testable import FlightRider
import UIKit
import XCTest
import CoreData

class SelectSeatsInteractorTests: XCTestCase {

    // MARK: - Subject under test

    var sut: SelectSeatsInteractor!
    var context: NSManagedObjectContext!

    // MARK: - Test lifecycle

    override func setUp() {
        super.setUp()
        setupSelectSeatsInteractor()
        context = setUpInMemoryManagedObjectContext()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Test setup

    func setupSelectSeatsInteractor() {
        sut = SelectSeatsInteractor()
    }

    func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])

        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)

        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch {
            print("Adding in-memory persistent store failed")
        }

        let managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator

        return managedObjectContext
    }

    class SelectSeatsPresentationLogicMock: SelectSeatsPresentationLogic {

        var requestPickerInitializationCalled = false
        var fetchCheckSeatsDataCalled = false
        var fetchDisplayDataCalled = false
        var fetchPickerDataModelCalled = false
        var fetchUpdateSeatResultCalled = false

        var model: SelectSeats.PickerDataModel.Response!

        func requestPickerInitialization(request: SelectSeats.PickerDataSource.Request) {
            requestPickerInitializationCalled = true
        }

        func fetchCheckSeatsData(dataModel: SelectSeats.StoredData.CheckSeatsModel) {
            fetchCheckSeatsDataCalled = true
        }

        func fetchDisplayData(response: SelectSeats.DisplayData.Response) {
            fetchDisplayDataCalled = true
        }

        func fetchPickerDataModel(response: SelectSeats.PickerDataModel.Response) {
            fetchPickerDataModelCalled = true
            model = response
        }

        func fetchUpdateSeatResult(response: SelectSeats.UpdateSeat.Response) {
            fetchUpdateSeatResultCalled = true
        }

    }

    class SelectSeatsWorkerMock: SelectSeatsWorkerProtocol {
        var requestPickerInitializationCalled = false
        var requestUpdateSeatCalled = false

        func requestPickerInitialization(request: SelectSeats.PickerDataSource.Request) {
            requestPickerInitializationCalled = true
        }

        func requestUpdateSeat(request: SelectSeats.UpdateSeat.Request) {
            requestUpdateSeatCalled = true
        }

    }

    func testFetchPickerDataSource() {
        // Given
        let selectSeatsPresentationLogicMock = SelectSeatsPresentationLogicMock()
        let selectSeatsWorkerMock = SelectSeatsWorkerMock()
        sut.presenter = selectSeatsPresentationLogicMock
        sut.worker = selectSeatsWorkerMock

        let flight = ManagedFlight(context: context)
        flight.airplaneType = "dummy"
        sut.dataStore = SelectSeats.StoredData.ViewModel(flight: flight, user: nil, userRecord: nil, image: nil, justSelectedSeat: true)

        // When
        var jsondata = [JSON]()
        let json = """
        {"modelName": "dummy", "numberOfSeats": 32, "columns": "ABCDEF"}
        """
        jsondata.append(JSON(parseJSON: json))
        let response = SelectSeats.PickerDataSource.Response(dataSource: jsondata)
        sut.fetchPickerDataSource(response: response)

        // Then
        XCTAssert(selectSeatsPresentationLogicMock.fetchPickerDataModelCalled == true)
        XCTAssert(selectSeatsPresentationLogicMock.model.airplaneModel.modelName == "dummy")
        XCTAssert(selectSeatsPresentationLogicMock.model.airplaneModel.columns == "ABCDEF")
        XCTAssert(selectSeatsPresentationLogicMock.model.airplaneModel.numberOfSeats == 32)
    }

    func testFetchPickerDataSourceWrongModel() {
        // Given
        let selectSeatsPresentationLogicMock = SelectSeatsPresentationLogicMock()
        let selectSeatsWorkerMock = SelectSeatsWorkerMock()
        sut.presenter = selectSeatsPresentationLogicMock
        sut.worker = selectSeatsWorkerMock

        let flight = ManagedFlight(context: context)
        flight.airplaneType = "dummy"
        sut.dataStore = SelectSeats.StoredData.ViewModel(flight: flight, user: nil, userRecord: nil, image: nil, justSelectedSeat: true)

        // When
        var jsondata = [JSON]()
        let json = """
        {"modelName": "NotDummy", "numberOfSeats": 32, "columns": "ABCDEF"}
        """
        jsondata.append(JSON(parseJSON: json))
        let response = SelectSeats.PickerDataSource.Response(dataSource: jsondata)
        sut.fetchPickerDataSource(response: response)

        // Then
        XCTAssert(selectSeatsPresentationLogicMock.fetchPickerDataModelCalled == false)
        XCTAssert(selectSeatsPresentationLogicMock.model == nil)
    }

    func testFetchPickerDataSourcenilModel() {
        // Given
        let selectSeatsPresentationLogicMock = SelectSeatsPresentationLogicMock()
        let selectSeatsWorkerMock = SelectSeatsWorkerMock()
        sut.presenter = selectSeatsPresentationLogicMock
        sut.worker = selectSeatsWorkerMock

        let flight = ManagedFlight(context: context)
        sut.dataStore = SelectSeats.StoredData.ViewModel(flight: flight, user: nil, userRecord: nil, image: nil, justSelectedSeat: true)

        // When
        var jsondata = [JSON]()
        let json = """
        {"modelName": "NotDummy", "numberOfSeats": 32, "columns": "ABCDEF"}
        """
        jsondata.append(JSON(parseJSON: json))
        let response = SelectSeats.PickerDataSource.Response(dataSource: jsondata)
        sut.fetchPickerDataSource(response: response)

        // Then
        XCTAssert(selectSeatsPresentationLogicMock.fetchPickerDataModelCalled == false)
        XCTAssert(selectSeatsPresentationLogicMock.model == nil)
    }
}

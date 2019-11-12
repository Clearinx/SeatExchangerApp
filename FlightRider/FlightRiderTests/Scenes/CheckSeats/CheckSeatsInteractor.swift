//
//  CheckSeatsInteractorTests.swift
//  FlightRiderTests
//
//  Created by Tamas Attila Horvath on 2019. 11. 12..
//  Copyright © 2019. Tomi. All rights reserved.
//

@testable import FlightRider
import UIKit
import XCTest
import CoreData

class CheckSeatsInteractorTests: XCTestCase{
    
    // MARK: - Subject under test
    
    var sut: CheckSeatsInteractor!
    var context : NSManagedObjectContext!
    
    // MARK: - Test lifecycle
    
    override func setUp()
    {
        super.setUp()
        setupCheckSeatsInteractor()
        context = setUpInMemoryManagedObjectContext()
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    // MARK: - Test setup
    
    func setupCheckSeatsInteractor()
    {
        sut = CheckSeatsInteractor()
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
    
    class CheckSeatsPresentationLogicMock: CheckSeatsPresentationLogic
    {
        var fetchAirplaneModelCalled = false
        var fetchJustSelectedSeatFlagCalled = false
        
        func fetchAirplaneModel(response: CheckSeats.GetAirplaneModel.Response) {
            fetchAirplaneModelCalled = true
        }
        
        func fetchJustSelectedSeatFlag(response: CheckSeats.JustSelecetedSeatStatus.Response) {
            fetchJustSelectedSeatFlagCalled = true
        }
        
        
    }
    
    class CheckSeatsWorkerMock : CheckSeatsWorkerProtocol
    {
        var interactor: CheckSeatsBusinessLogic?
        
        var requestAirplaneModel = false
        
        func requestAirplaneModel(request: CheckSeats.GetAirplaneModel.Request) {
            requestAirplaneModel = true
        }

    }
    
    func testGetSeatStatusFound(){
        // Given
        let checkSeatsPresentationLogicMock = CheckSeatsPresentationLogicMock()
        let checkSeatsWorkerMock = CheckSeatsWorkerMock()
        sut.presenter = checkSeatsPresentationLogicMock
        sut.worker = checkSeatsWorkerMock
        
         // When
        let flight = ManagedFlight(context: context)
        let seat = ManagedSeat(context: context)
        seat.number = "01A"
        seat.changetag = "dummy"
        seat.occupiedBy = "dummyUser"
        seat.uid = "dummyUid"
        flight.seats.insert(seat)
        sut.dataStore = CheckSeats.DataStore.DataStore(flight: flight, user: nil, justSelectedSeat: nil)
        let plane = AirplaneModel(modelName: "dummy", numberOfSeats: 32, latestColumn: "ABCDEF")
        let result = sut.getSeatStatus(row: 1, column: 0, model: plane)
        
        // Then
        var expectedResult = Set<ManagedSeat>()
        expectedResult.insert(seat)
        XCTAssert(result.count == expectedResult.count)
    }
    
    func testGetSeatStatusNotFound(){
        // Given
        let checkSeatsPresentationLogicMock = CheckSeatsPresentationLogicMock()
        let checkSeatsWorkerMock = CheckSeatsWorkerMock()
        sut.presenter = checkSeatsPresentationLogicMock
        sut.worker = checkSeatsWorkerMock
        
        // When
        let flight = ManagedFlight(context: context)
        let seat = ManagedSeat(context: context)
        seat.number = "12A"
        seat.changetag = "dummy"
        seat.occupiedBy = "dummyUser"
        seat.uid = "dummyUid"
        flight.seats.insert(seat)
        sut.dataStore = CheckSeats.DataStore.DataStore(flight: flight, user: nil, justSelectedSeat: nil)
        let plane = AirplaneModel(modelName: "dummy", numberOfSeats: 32, latestColumn: "ABCDEF")
        let result = sut.getSeatStatus(row: 5, column: 3, model: plane)
        
        // Then
        var expectedResult = Set<ManagedSeat>()
        expectedResult.insert(seat)
        XCTAssert(result.count == 0)
    }
    
    func testGetSeatStatusInvalidSeat(){
        // Given
        let checkSeatsPresentationLogicMock = CheckSeatsPresentationLogicMock()
        let checkSeatsWorkerMock = CheckSeatsWorkerMock()
        sut.presenter = checkSeatsPresentationLogicMock
        sut.worker = checkSeatsWorkerMock
        
         // When
        let flight = ManagedFlight(context: context)
        let seat = ManagedSeat(context: context)
        seat.number = "CCX"
        seat.changetag = "dummy"
        seat.occupiedBy = "dummyUser"
        seat.uid = "dummyUid"
        flight.seats.insert(seat)
        sut.dataStore = CheckSeats.DataStore.DataStore(flight: flight, user: nil, justSelectedSeat: nil)
        let plane = AirplaneModel(modelName: "dummy", numberOfSeats: 32, latestColumn: "ABCDEF")
        let result = sut.getSeatStatus(row: 1, column: 3, model: plane)
        
        // Then
        var expectedResult = Set<ManagedSeat>()
        expectedResult.insert(seat)
        XCTAssert(result.count == 0)
    }
    
    func testGetSeatStatusFoundLast(){
        // Given
        let checkSeatsPresentationLogicMock = CheckSeatsPresentationLogicMock()
        let checkSeatsWorkerMock = CheckSeatsWorkerMock()
        sut.presenter = checkSeatsPresentationLogicMock
        sut.worker = checkSeatsWorkerMock
        
        // When
        let flight = ManagedFlight(context: context)
        let seat = ManagedSeat(context: context)
        seat.number = "32F"
        seat.changetag = "dummy"
        seat.occupiedBy = "dummyUser"
        seat.uid = "dummyUid"
        flight.seats.insert(seat)
        
        sut.dataStore = CheckSeats.DataStore.DataStore(flight: flight, user: nil, justSelectedSeat: nil)
        
        let plane = AirplaneModel(modelName: "dummy", numberOfSeats: 32, latestColumn: "ABCDEF")
        let result = sut.getSeatStatus(row: 32, column: 5, model: plane)
        
        
        // Then
        var expectedResult = Set<ManagedSeat>()
        expectedResult.insert(seat)
        XCTAssert(result.count == 0)
    }
}

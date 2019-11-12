//
//  CheckSeatsWorkerTests.swift
//  FlightRiderTests
//
//  Created by Tomi on 2019. 11. 12..
//  Copyright © 2019. Tomi. All rights reserved.
//

@testable import FlightRider
import UIKit
import XCTest

class CheckSeatsWorkerTests: XCTestCase
{
    // MARK: - Subject under test
    
    var sut: CheckSeatsWorker!
    
    // MARK: - Test lifecycle
    
    override func setUp()
    {
        super.setUp()
        setupCheckSeatsWorker()
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    // MARK: - Test setup
    
    func setupCheckSeatsWorker()
    {
        sut = CheckSeatsWorker()
    }
    
    // MARK: - Test doubles
    
    class CheckSeatsBusinessLogicSpy: CheckSeatsBusinessLogic{
        
        var requestAirplaneModelCalled = false
        var requestJustSelectedSeatFlagCalled = false
        var fetchAirplaneModelCalled = false
        var pushDataFromPreviousViewControllerCalled = false
        var pushDataFromPreviousViewControllerStoredDataCalled = false
        var getSeatStatusCalled = false
        var getUserEmailCalled = false
        
        var model : CheckSeats.GetAirplaneModel.Response!
        
        func requestAirplaneModel(request: inout CheckSeats.GetAirplaneModel.Request) {
            requestAirplaneModelCalled = true
        }
        
        func requestJustSelectedSeatFlag(request: CheckSeats.JustSelecetedSeatStatus.Request) {
            requestJustSelectedSeatFlagCalled = true
        }
        
        func fetchAirplaneModel(response: CheckSeats.GetAirplaneModel.Response) {
            fetchAirplaneModelCalled = true
            model = response
        }
        
        func pushDataFromPreviousViewController(viewModel: SelectSeats.StoredData.CheckSeatsModel) {
            pushDataFromPreviousViewControllerCalled = true
        }
        
        func pushDataFromPreviousViewController(viewModel: ListFlights.CheckSeatsData.DataStore) {
            pushDataFromPreviousViewControllerStoredDataCalled = true
        }
        
        func getSeatStatus(row: Int, column: Int, model: AirplaneModel) -> Set<ManagedSeat> {
            getSeatStatusCalled = true
            return Set<ManagedSeat>()
        }
        
        func getUserEmail() -> String {
            getUserEmailCalled = true
            return ""
        }
    }
    
    func testRequestAirplaneModel()
    {
        // Given
        let checkSeatsBusinessLogicSpy = CheckSeatsBusinessLogicSpy()
        sut.interactor = checkSeatsBusinessLogicSpy
        
        // When
        let request = CheckSeats.GetAirplaneModel.Request(airplaneType: "dummy")
        sut.requestAirplaneModel(request: request)
        
        // Then
        let expectedModelName = "dummy"
        XCTAssert(checkSeatsBusinessLogicSpy.fetchAirplaneModelCalled == true)
        XCTAssert(checkSeatsBusinessLogicSpy.model.airplaneModel.modelName == expectedModelName)
    }
    
    func testRequestAirplaneModelWrongModel()
    {
        // Given
        let checkSeatsBusinessLogicSpy = CheckSeatsBusinessLogicSpy()
        sut.interactor = checkSeatsBusinessLogicSpy
        
        // When
        let request = CheckSeats.GetAirplaneModel.Request(airplaneType: "NotDummy")
        sut.requestAirplaneModel(request: request)
        
        // Then
        XCTAssert(checkSeatsBusinessLogicSpy.fetchAirplaneModelCalled == false)
    }
    
    func testRequestAirplaneModelNilModel()
    {
        // Given
        let checkSeatsBusinessLogicSpy = CheckSeatsBusinessLogicSpy()
        sut.interactor = checkSeatsBusinessLogicSpy
        
        // When
        let request = CheckSeats.GetAirplaneModel.Request(airplaneType: nil)
        sut.requestAirplaneModel(request: request)
        
        // Then
        XCTAssert(checkSeatsBusinessLogicSpy.fetchAirplaneModelCalled == false)
    }
}

//
//  CheckSeatsViewControllerTests.swift
//  FlightRiderTests
//
//  Created by Tomi on 2019. 11. 12..
//  Copyright © 2019. Tomi. All rights reserved.
//

@testable import FlightRider
import UIKit
import XCTest

class CheckSeatsViewControllerTests: XCTestCase
{
    // MARK: - Subject under test
    
    var sut: CheckSeatsViewController!
    
    // MARK: - Test lifecycle
    
    override func setUp()
    {
        super.setUp()
        setupCheckSeatsViewController()
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    // MARK: - Test setup
    
    func setupCheckSeatsViewController()
    {
        sut = CheckSeatsViewController()
    }
    
    // MARK: - Test doubles
    
    class CheckSeatsBusinessLogicSpy: CheckSeatsBusinessLogic, CheckSeatsDataStore
    {
        var dataStore = CheckSeats.DataStore.DataStore()
        
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
}

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

class SelectSeatsInteractorTests: XCTestCase{
    
    // MARK: - Subject under test
    
    var sut: SelectSeatsInteractor!
    
    // MARK: - Test lifecycle
    
    override func setUp()
    {
        super.setUp()
        setupSelectSeatsInteractor()
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    // MARK: - Test setup
    
    func setupSelectSeatsInteractor()
    {
        sut = SelectSeatsInteractor()
    }
    
    class SelectSeatsPresentationLogicMock: SelectSeatsPresentationLogic
    {
        
        var requestPickerInitializationCalled = false
        var fetchCheckSeatsDataCalled = false
        var fetchDisplayDataCalled = false
        var fetchPickerDataModelCalled = false
        var fetchUpdateSeatResultCalled = false
        
        var model : SelectSeats.PickerDataModel.Response!
        
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
    
    class SelectSeatsWorkerMock : SelectSeatsWorkerProtocol
    {
        var requestPickerInitializationCalled = false
        var requestUpdateSeatCalled = false
        
        func requestPickerInitialization(request: SelectSeats.PickerDataSource.Request) {
            requestPickerInitializationCalled = true
        }
        
        func requestUpdateSeat(request: SelectSeats.UpdateSeat.Request) {
            requestUpdateSeatCalled = true
        }

    }
    
    func testFetchPickerDataSource(){
        // Given
        let selectSeatsPresentationLogicMock = SelectSeatsPresentationLogicMock()
        let selectSeatsWorkerMock = SelectSeatsWorkerMock()
        sut.presenter = selectSeatsPresentationLogicMock
        sut.worker = selectSeatsWorkerMock
        
        // When
        var jsondata = [JSON]()
        let json = """
        [{"modelName": "dummy", "numberOfSeats": 32, "columns": "ABCDEF"}]
        """
        jsondata.append(JSON(parseJSON: json))
        print(jsondata)
        let response = SelectSeats.PickerDataSource.Response(dataSource: jsondata)
        sut.fetchPickerDataSource(response: response)
        
        // Then
        XCTAssert(selectSeatsPresentationLogicMock.model.airplaneModel.modelName == "dummy")
        XCTAssert(selectSeatsPresentationLogicMock.model.airplaneModel.columns == "ABCDEF")
        XCTAssert(selectSeatsPresentationLogicMock.model.airplaneModel.numberOfSeats == 32)
    }
}

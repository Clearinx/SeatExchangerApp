//
//  SelectSeatsPresenter.swift
//  FlightRiderTests
//
//  Created by Tomi on 2019. 11. 12..
//  Copyright © 2019. Tomi. All rights reserved.
//

@testable import FlightRider
import UIKit
import XCTest

class SelectSeatsPresenterTests: XCTestCase
{
    // MARK: - Subject under test
    
    var sut: SelectSeatsPresenter!
    
    // MARK: - Test lifecycle
    
    override func setUp()
    {
        super.setUp()
        setupSelectSeatsPresenter()
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    // MARK: - Test setup
    
    func setupSelectSeatsPresenter()
    {
        sut = SelectSeatsPresenter()
    }
    
    class SelectSeatsDisplayLogicMock: SelectSeatsDisplayLogic
    {
        
        var fetchDataFromPreviousViewControllerCalled = false
        var displayDataCalled = false
        var displayPickerViewCalled = false
        var displaySuccessfulSeatUpdateCalled = false
        var displayUnsuccessfulSeatUpdateCalled = false
        var routeToCheckSeatsCalled = false
        
        var pickerModel : SelectSeats.PickerDataModel.ViewModel!
        
        func fetchDataFromPreviousViewController(viewModel: ListFlights.SelectSeatsData.ViewModel) {
            fetchDataFromPreviousViewControllerCalled = true
        }
        
        func displayData(viewModel: SelectSeats.DisplayData.ViewModel) {
            displayDataCalled = true
        }
        
        func displayPickerView(viewModel: SelectSeats.PickerDataModel.ViewModel) {
            displayPickerViewCalled = true
            pickerModel = viewModel
        }
        
        func displaySuccessfulSeatUpdate(response: SelectSeats.UpdateSeat.Response) {
            displaySuccessfulSeatUpdateCalled = true
        }
        
        func displayUnsuccessfulSeatUpdate(response: SelectSeats.UpdateSeat.Response) {
            displayUnsuccessfulSeatUpdateCalled = true
        }
        
        func routeToCheckSeats(dataModel: SelectSeats.StoredData.CheckSeatsModel) {
            routeToCheckSeatsCalled = true
        }
    }
    
    func testFetchPickerDataModel()
    {
        // Given
        let selectSeatsDisplayLogicMock = SelectSeatsDisplayLogicMock()
        sut.viewController = selectSeatsDisplayLogicMock
        
        // When
        let model = AirplaneModel(modelName: "dummy", numberOfSeats: 32, latestColumn: "ABCDEF")
        let response = SelectSeats.PickerDataModel.Response(airplaneModel: model)
        sut.fetchPickerDataModel(response: response)
        
        // Then
        XCTAssert(selectSeatsDisplayLogicMock.displayPickerViewCalled == true)
        XCTAssert(selectSeatsDisplayLogicMock.pickerModel.pickerDataNumbers.count == model.numberOfSeats)
    }
    
    func testFetchPickerDataModelLotOfSeats()
    {
        // Given
        let selectSeatsDisplayLogicMock = SelectSeatsDisplayLogicMock()
        sut.viewController = selectSeatsDisplayLogicMock
        
        // When
        let model = AirplaneModel(modelName: "NotDummy", numberOfSeats: 1358, latestColumn: "ABCDEF")
        let response = SelectSeats.PickerDataModel.Response(airplaneModel: model)
        sut.fetchPickerDataModel(response: response)
        
        // Then
        XCTAssert(selectSeatsDisplayLogicMock.displayPickerViewCalled == true)
        XCTAssert(selectSeatsDisplayLogicMock.pickerModel.pickerDataNumbers.count == model.numberOfSeats)
    }
    
    func testFetchPickerDataModelLotOfLetters()
    {
        // Given
        let selectSeatsDisplayLogicMock = SelectSeatsDisplayLogicMock()
        sut.viewController = selectSeatsDisplayLogicMock
        
        // When
        let model = AirplaneModel(modelName: "NotDummy", numberOfSeats: 1358, latestColumn: "ABCDEFGHIJKLMNOPQR")
        let response = SelectSeats.PickerDataModel.Response(airplaneModel: model)
        sut.fetchPickerDataModel(response: response)
        
        // Then
        XCTAssert(selectSeatsDisplayLogicMock.displayPickerViewCalled == true)
        XCTAssert(selectSeatsDisplayLogicMock.pickerModel.pickerData[1].count == model.columns.count)
    }
    
    
    func testFetchUpdateSeatResultTrue()
    {
        // Given
        let selectSeatsDisplayLogicMock = SelectSeatsDisplayLogicMock()
        sut.viewController = selectSeatsDisplayLogicMock
        
        // When
        let response = SelectSeats.UpdateSeat.Response(result: true, selectedSeatNumber: nil, errorMessage: nil)
        sut.fetchUpdateSeatResult(response: response)
        
        // Then
        XCTAssert(selectSeatsDisplayLogicMock.displaySuccessfulSeatUpdateCalled == true)
        XCTAssert(selectSeatsDisplayLogicMock.displayUnsuccessfulSeatUpdateCalled == false)
    }
    
    func testFetchUpdateSeatResultFalse()
    {
        // Given
        let selectSeatsDisplayLogicMock = SelectSeatsDisplayLogicMock()
        sut.viewController = selectSeatsDisplayLogicMock
        
        // When
        let response = SelectSeats.UpdateSeat.Response(result: false, selectedSeatNumber: nil, errorMessage: nil)
        sut.fetchUpdateSeatResult(response: response)
        
        // Then
        XCTAssert(selectSeatsDisplayLogicMock.displaySuccessfulSeatUpdateCalled == false)
        XCTAssert(selectSeatsDisplayLogicMock.displayUnsuccessfulSeatUpdateCalled == true)
    }
    
}

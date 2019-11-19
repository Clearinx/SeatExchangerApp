//
//  CannotCheckInPresenterTests.swift
//  FlightRiderTests
//
//  Created by Tamas Attila Horvath on 2019. 11. 10..
//  Copyright © 2019. Tomi. All rights reserved.
//

@testable import FlightRider
import UIKit
import XCTest

class CannotCheckInPresenterTests: XCTestCase {
    // MARK: - Subject under test

    var sut: CannotCheckInPresenter!

    // MARK: - Test lifecycle

    override func setUp() {
        super.setUp()
        setupCannotCheckInPresenter()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Test setup

    func setupCannotCheckInPresenter() {
        sut = CannotCheckInPresenter()
    }

    class CannotCheckInDisplayLogicMock: CannotCheckInDisplayLogic {
        var fetchDataFromPreviousViewControllerCalled = false
        var fetchStoredDataCalled = false
        var displayRemainingTimeCalled = false
        var displayStoredDataCalled = false

        var time: CannotCheckIn.CalculateTime.Response!

        func fetchDataFromPreviousViewController(viewModel: ListFlights.CannotCheckinData.ViewModel) {
            fetchDataFromPreviousViewControllerCalled = true
        }

        func fetchStoredData(viewModel: CannotCheckIn.StoredData.ViewModel) {
            fetchStoredDataCalled = true
        }

        func displayRemainingTime(response: CannotCheckIn.CalculateTime.Response) {
            displayRemainingTimeCalled = true
            time = response
        }

        func displayStoredData(viewModel: CannotCheckIn.StoredData.ViewModel) {
            displayStoredDataCalled = true
        }
    }

    func testRequestRemaningTimeCalculationActualDate() {
        // Given
        let cannotCheckInDisplayLogicMock = CannotCheckInDisplayLogicMock()
        sut.viewController = cannotCheckInDisplayLogicMock

        // When
        let request = CannotCheckIn.CalculateTime.Request(departureDate: Date())
        sut.requestRemaningTimeCalculation(request: request)

        // Then
        let expectedResponse = CannotCheckIn.CalculateTime.Response(days: "-2", hours: "0", minutes: "0")
        XCTAssert(cannotCheckInDisplayLogicMock.time.days == expectedResponse.days)
        XCTAssert(cannotCheckInDisplayLogicMock.time.hours == expectedResponse.hours)
        XCTAssert(cannotCheckInDisplayLogicMock.time.minutes == expectedResponse.minutes)
    }

    func testRequestRemaningTimeCalculationPlus30D() {
        // Given
        let cannotCheckInDisplayLogicMock = CannotCheckInDisplayLogicMock()
        sut.viewController = cannotCheckInDisplayLogicMock

        // When
        let request = CannotCheckIn.CalculateTime.Request(departureDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()))
        sut.requestRemaningTimeCalculation(request: request)

        // Then
        let expectedResponse = CannotCheckIn.CalculateTime.Response(days: "27", hours: "23", minutes: "59")
        XCTAssert(cannotCheckInDisplayLogicMock.time.days == expectedResponse.days)
        XCTAssert(cannotCheckInDisplayLogicMock.time.hours == expectedResponse.hours)
        XCTAssert(cannotCheckInDisplayLogicMock.time.minutes == expectedResponse.minutes)
    }

    func testRequestRemaningTimeCalculationPlus72Hour() {
        // Given
        let cannotCheckInDisplayLogicMock = CannotCheckInDisplayLogicMock()
        sut.viewController = cannotCheckInDisplayLogicMock

        // When
        let request = CannotCheckIn.CalculateTime.Request(departureDate: Calendar.current.date(byAdding: .hour, value: 72, to: Date()))
        sut.requestRemaningTimeCalculation(request: request)

        // Then
        let expectedResponse = CannotCheckIn.CalculateTime.Response(days: "0", hours: "23", minutes: "59")
        XCTAssert(cannotCheckInDisplayLogicMock.time.days == expectedResponse.days)
        XCTAssert(cannotCheckInDisplayLogicMock.time.hours == expectedResponse.hours)
        XCTAssert(cannotCheckInDisplayLogicMock.time.minutes == expectedResponse.minutes)
    }
}

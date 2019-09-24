//
//  FlightRiderUITests.swift
//  FlightRiderUITests
//
//  Created by Tomi on 2019. 07. 19..
//  Copyright © 2019. Tomi. All rights reserved.
//

import XCTest

class FlightRiderUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = true

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        
        let app = XCUIApplication()
        app.textFields["E-mail"].tap()
        app.textFields["E-mail"].typeText("a@a.hu")
        
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText("Password")
        app.buttons["Login"].tap()
        
        sleep(5)
        
        let cells = XCUIApplication().tables.cells
        print(cells.count)
        var i = cells.count
        while i != 0 {
            cells.firstMatch.swipeLeft()
            if(cells.firstMatch.buttons["Delete"].exists){
                cells.firstMatch.buttons["Delete"].tap()
                i -= 1
                sleep(3)
            }
        }
        sleep(5)
        XCTAssertEqual(cells.count, 0, "Finished")
        

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        
        let cells = XCUIApplication().tables.cells
        print(cells.count)
        var i = cells.count
        while i != 0 {
            cells.firstMatch.swipeLeft()
            if(cells.firstMatch.buttons["Delete"].exists){
                cells.firstMatch.buttons["Delete"].tap()
                i -= 1
                sleep(3)
            }
        }
        sleep(5)
        XCTAssertEqual(cells.count, 0, "Finished")
    }
    
    func testAddElementsToList(){
        
        let app = XCUIApplication()
        let table = app.tables
        let flightsArray = ["FR110", "FR114", "U2555"]
        XCTAssertEqual(table.cells.count, 0, "Empty")
        for flight in flightsArray{
            app.navigationBars["Flights"].buttons["Add"].tap()
            
            let enterTheDepartureDateAndTheFlightNumberAlert = app.alerts["Enter the departure date and the flight number"]
            
            let textField = enterTheDepartureDateAndTheFlightNumberAlert.collectionViews.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .textField).element
            textField.typeText(flight)
            
            let submitButton = enterTheDepartureDateAndTheFlightNumberAlert.buttons["Submit"]
            submitButton.tap()
            
            print("start")
            sleep(5)
            print("finish")
        }
        
        XCTAssertEqual(table.cells.count, 3, "Finished")
        XCTAssertTrue(table.cells.element(boundBy:0).staticTexts[flightsArray[0]].exists)
        XCTAssertTrue(table.cells.element(boundBy:1).staticTexts[flightsArray[1]].exists)
        XCTAssertTrue(table.cells.element(boundBy:2).staticTexts[flightsArray[2]].exists)
        
    }
    
    func testAddInvalidItemToList(){
        
        let app = XCUIApplication()
        let table = app.tables
        let flight = "IV999"
        XCTAssertEqual(table.cells.count, 0, "Empty")
        app.navigationBars["Flights"].buttons["Add"].tap()
            
        let enterTheDepartureDateAndTheFlightNumberAlert = app.alerts["Enter the departure date and the flight number"]
            
        let textField = enterTheDepartureDateAndTheFlightNumberAlert.collectionViews.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .textField).element
            textField.typeText(flight)
            
        let submitButton = enterTheDepartureDateAndTheFlightNumberAlert.buttons["Submit"]
        submitButton.tap()
            
        print("start")
        sleep(5)
        print("finish")
        
        XCTAssertEqual(table.cells.count, 0, "Finished")
        XCTAssert(app.alerts["Error"].exists)
        app.alerts["Error"].buttons["Ok"].tap()
        
    }
    
    func testAddDuplicateItemToList(){
        
        let app = XCUIApplication()
        let table = app.tables
        let flight = "FR6752"
        XCTAssertEqual(table.cells.count, 0, "Empty")
        app.navigationBars["Flights"].buttons["Add"].tap()
        
        var enterTheDepartureDateAndTheFlightNumberAlert = app.alerts["Enter the departure date and the flight number"]
        
        var textField = enterTheDepartureDateAndTheFlightNumberAlert.collectionViews.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .textField).element
        textField.typeText(flight)
        
        var submitButton = enterTheDepartureDateAndTheFlightNumberAlert.buttons["Submit"]
        submitButton.tap()
        
        sleep(5)
        
        XCTAssertEqual(table.cells.count, 1, "Finished")
        
        app.navigationBars["Flights"].buttons["Add"].tap()
        
        enterTheDepartureDateAndTheFlightNumberAlert = app.alerts["Enter the departure date and the flight number"]
        
        textField = enterTheDepartureDateAndTheFlightNumberAlert.collectionViews.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .textField).element
        textField.typeText(flight)
        
        submitButton = enterTheDepartureDateAndTheFlightNumberAlert.buttons["Submit"]
        submitButton.tap()
        
        sleep(5)
        
        XCTAssertEqual(table.cells.count, 1, "Finished")
        XCTAssert(app.alerts["Error"].exists)
        app.alerts["Error"].buttons["Ok"].tap()
        
    }
    
    func testCheckSeats() {
        
        let app = XCUIApplication()
        
        app.navigationBars["Flights"].buttons["Add"].tap()
        
        let enterTheDepartureDateAndTheFlightNumberAlert = app.alerts["Enter the departure date and the flight number"]
        
        let textField = enterTheDepartureDateAndTheFlightNumberAlert.collectionViews.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .textField).element
        textField.typeText("FR8417")
        
        let submitButton = enterTheDepartureDateAndTheFlightNumberAlert.buttons["Submit"]
        submitButton.tap()
        
        print("start")
        sleep(2)
        print("finish")
        app.tables.cells.element(boundBy:0).tap()
        
        app.navigationBars["FlightRider.FlightDetailView"].buttons["Done"].tap()
        
        app.navigationBars["FlightRider.CheckSeatsView"].buttons["< Back"].tap()
        app.navigationBars["FlightRider.FlightDetailView"].buttons["Flights"].tap()
        XCTAssertEqual(app.tables.cells.count, 1, "We are on the flight list screen")
        
 
    }
    
    func testSelectSeat() {
        let app = XCUIApplication()
        
        app.navigationBars["Flights"].buttons["Add"].tap()
        
        let enterTheDepartureDateAndTheFlightNumberAlert = app.alerts["Enter the departure date and the flight number"]
        
        let textField = enterTheDepartureDateAndTheFlightNumberAlert.collectionViews.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .textField).element
        textField.typeText("FR4090")
        
        let submitButton = enterTheDepartureDateAndTheFlightNumberAlert.buttons["Submit"]
        submitButton.tap()
        
        print("start")
        sleep(2)
        print("finish")
        app.tables.cells.element(boundBy:0).tap()
        
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "15")
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "F")
         
         
         let updateButton = app.buttons["Update"]
         updateButton.tap()
        
        app.navigationBars["FlightRider.FlightDetailView"].buttons["Done"].tap()
        
        app.navigationBars["FlightRider.CheckSeatsView"].buttons["< Back"].tap()
        XCTAssertEqual(app.tables.cells.count, 1, "We are on the flight list screen")
    }
    
    func testDepartureDateTooFar() {
        let app = XCUIApplication()
        
        app.navigationBars["Flights"].buttons["Add"].tap()
        
        let enterTheDepartureDateAndTheFlightNumberAlert = app.alerts["Enter the departure date and the flight number"]
        let date = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
        let cal = Calendar.current
        let day = cal.component(.year, from:date)
        enterTheDepartureDateAndTheFlightNumberAlert.datePickers.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: String(day))
        
        let textField = enterTheDepartureDateAndTheFlightNumberAlert.collectionViews.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .textField).element
        textField.typeText("EI155")
        
        let submitButton = enterTheDepartureDateAndTheFlightNumberAlert.buttons["Submit"]
        submitButton.tap()
        
        print("start")
        sleep(2)
        print("finish")
        app.tables.cells.element(boundBy:0).tap()
        XCTAssertEqual(app.pickerWheels.count, 0, "Date too far, cannot select flight yet")
        app.navigationBars["FlightRider.FlightDetailView"].buttons["Flights"].tap()
    }

}

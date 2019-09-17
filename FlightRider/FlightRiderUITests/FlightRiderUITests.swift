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
        
        app.textFields["Password"].tap()
        app.textFields["Password"].typeText("Password")
        app.buttons["Login"].tap()
        
        let table = app.tables
        print("start")
        sleep(3)
        print("finish")
        
        

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
            }
        }
        XCTAssertEqual(cells.count, 0, "Finished")
    }
    
    func testAddElementsToList(){
        
        let app = XCUIApplication()
        let table = app.tables
        XCTAssertEqual(table.cells.count, 0, "Empty")
        for i in 1...3{
            app.navigationBars["Flights"].buttons["Add"].tap()
            
            let enterTheDepartureDateAndTheFlightNumberAlert = app.alerts["Enter the departure date and the flight number"]
            enterTheDepartureDateAndTheFlightNumberAlert.datePickers.pickerWheels["18"]
            
            let textField = enterTheDepartureDateAndTheFlightNumberAlert.collectionViews.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .textField).element
            textField.typeText("AAA\(i)\(i)\(i)")
            
            let submitButton = enterTheDepartureDateAndTheFlightNumberAlert.buttons["Submit"]
            submitButton.tap()
            
            print("start")
            sleep(2)
            print("finish")
        }
        
        XCTAssertEqual(table.cells.count, 3, "Finished")
        XCTAssertTrue(table.cells.element(boundBy:0).staticTexts["AAA111"].exists)
        XCTAssertTrue(table.cells.element(boundBy:1).staticTexts["AAA222"].exists)
        XCTAssertTrue(table.cells.element(boundBy:2).staticTexts["AAA333"].exists)
        
    }
    
    func testCheckSeats() {
        
        let app = XCUIApplication()
        
        app.navigationBars["Flights"].buttons["Add"].tap()
        
        let enterTheDepartureDateAndTheFlightNumberAlert = app.alerts["Enter the departure date and the flight number"]
        enterTheDepartureDateAndTheFlightNumberAlert.datePickers.pickerWheels["18"]
        
        let textField = enterTheDepartureDateAndTheFlightNumberAlert.collectionViews.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .textField).element
        textField.typeText("AAA111")
        
        let submitButton = enterTheDepartureDateAndTheFlightNumberAlert.buttons["Submit"]
        submitButton.tap()
        
        print("start")
        sleep(2)
        print("finish")
        app.tables.cells.element(boundBy:0).tap()
        
        /*app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "15")
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "F")


        let updateButton = app.buttons["Update"]
        updateButton.tap()*/
        
        app.navigationBars["FlightRider.FlightDetailView"].buttons["Done"].tap()
        
        app.navigationBars["FlightRider.CheckSeatsView"].buttons["< Back"].tap()
        app.navigationBars["FlightRider.FlightDetailView"].buttons["Flights"].tap()
        XCTAssertEqual(app.tables.cells.count, 1, "We are on the flight list screen")
        
 
    }
    
    func testSelectSeat() {
        let app = XCUIApplication()
        
        app.navigationBars["Flights"].buttons["Add"].tap()
        
        let enterTheDepartureDateAndTheFlightNumberAlert = app.alerts["Enter the departure date and the flight number"]
        enterTheDepartureDateAndTheFlightNumberAlert.datePickers.pickerWheels["18"]
        
        let textField = enterTheDepartureDateAndTheFlightNumberAlert.collectionViews.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .textField).element
        textField.typeText("AAA111")
        
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
    
    func testInitialStateIsCorrect() {
        let app = XCUIApplication()
        
        app.navigationBars["Flights"].buttons["Add"].tap()
        
        let enterTheDepartureDateAndTheFlightNumberAlert = app.alerts["Enter the departure date and the flight number"]
        let date = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
        let cal = Calendar.current
        let day = cal.component(.day, from:date)
        enterTheDepartureDateAndTheFlightNumberAlert.datePickers.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: String(day))
        
        let textField = enterTheDepartureDateAndTheFlightNumberAlert.collectionViews.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .textField).element
        textField.typeText("XXX222")
        
        let submitButton = enterTheDepartureDateAndTheFlightNumberAlert.buttons["Submit"]
        submitButton.tap()
        
        print("start")
        sleep(2)
        print("finish")
        app.tables.cells.element(boundBy:0).tap()
        sleep(5)
    }

    /*func testInitialStateIsCorrect() {
        let table = XCUIApplication().tables
        XCTAssertEqual(table.cells.count, 0, "There should be 0 rows initially")
    }
    
    func testAddItemsToList() {
        /*let table = XCUIApplication().tables
        let app = XCUIApplication()
        app.navigationBars["FlightRider.View"].buttons["Add"].tap()
        app.typeText("a")
        app.alerts["Enter a flight number"].buttons["Submit"].tap()
        XCTAssertEqual(table.cells.count, 1, "There should be 0 rows initially")*/
        
        
        
        let app = XCUIApplication()
        let table = XCUIApplication().tables
        
        app.navigationBars["Flights"].buttons["Add"].tap()
    
        let textField = app.alerts["Enter a flight number"].collectionViews.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .textField).element
        textField.tap()
        textField.typeText("some text")
        app.alerts["Enter a flight number"].buttons["Submit"].tap()
        
        for i in 1...5{
        app.navigationBars["Flights"].buttons["Add"].tap()
        
        let textField = app.alerts["Enter a flight number"].collectionViews.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .textField).element
        textField.tap()
        textField.typeText(String(i))
        app.alerts["Enter a flight number"].buttons["Submit"].tap()
        
        
        }
        let cell = table.cells.element(boundBy:0).staticTexts["some text"]
        XCTAssertTrue(cell.exists)
        
        let cell2 = table.cells.element(boundBy:4).staticTexts["4"]
        XCTAssertTrue(cell2.exists)
        let cell3 = table.cells.element(boundBy:2).staticTexts["dummy"]
        XCTAssertFalse(cell3.exists)
        XCTAssertEqual(table.cells.count, 6, "There should be 5 rows")
    }
    
    func testAddAndRemoveItemsToList() {
        let app = XCUIApplication()
        let table = XCUIApplication().tables
        let flightriderViewNavigationBar = app.navigationBars["Flights"]
        
        for i in 1...3{
        app.navigationBars["Flights"].buttons["Add"].tap()
            
            let textField = app.alerts["Enter a flight number"].collectionViews.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .textField).element
            textField.tap()
            textField.typeText(String(i))
            app.alerts["Enter a flight number"].buttons["Submit"].tap()
            
            
        }
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["2"]/*[[".cells.staticTexts[\"2\"]",".staticTexts[\"2\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        flightriderViewNavigationBar.buttons["Delete"].tap()
        XCTAssertEqual(table.cells.count, 2, "There should be  rows")
        
        
        
    }
    func testIfImageViewAndSubtitleExists() {
        let app = XCUIApplication()
        let table = XCUIApplication().tables
        
        app.navigationBars["Flights"].buttons["Add"].tap()
        
        let textField = app.alerts["Enter a flight number"].collectionViews.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .textField).element
        textField.tap()
        textField.typeText("FR1234")
        app.alerts["Enter a flight number"].buttons["Submit"].tap()
        
        let cell = table.cells.element(boundBy:0)
        let txt = cell.staticTexts["FR1234"]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = formatter.string(from: Date())
        
        let subt = cell.staticTexts[date]
        let img = cell.images.element(boundBy: 0)
        
        XCTAssertTrue(cell.exists)
        XCTAssertTrue(txt.exists)
        XCTAssertTrue(subt.exists)
        XCTAssertTrue(img.exists)
        
    
        
        
    }*/
}

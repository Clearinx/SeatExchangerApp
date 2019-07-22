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
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        
        

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitialStateIsCorrect() {
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
        
        for i in 1...5{
        app.navigationBars["FlightRider.View"].buttons["Add"].tap()
        
        let textField = app.alerts["Enter a flight number"].collectionViews.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .textField).element
        textField.tap()
        textField.typeText(String(i))
        app.alerts["Enter a flight number"].buttons["Submit"].tap()
        
        
        }
        XCTAssertEqual(table.cells.count, 5, "There should be 5 rows")
    }
    
    func testAddAndRemoveItemsToList() {
        let app = XCUIApplication()
        let table = XCUIApplication().tables
        let flightriderViewNavigationBar = app.navigationBars["FlightRider.View"]
        
        for i in 1...3{
            app.navigationBars["FlightRider.View"].buttons["Add"].tap()
            
            let textField = app.alerts["Enter a flight number"].collectionViews.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .textField).element
            textField.tap()
            textField.typeText(String(i))
            app.alerts["Enter a flight number"].buttons["Submit"].tap()
            
            
        }
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["2"]/*[[".cells.staticTexts[\"2\"]",".staticTexts[\"2\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        flightriderViewNavigationBar.buttons["Delete"].tap()
        XCTAssertEqual(table.cells.count, 2, "There should be  rows")
        
        
        
    }
}

//
//  LoginPresenterTests.swift
//  FlightRiderTests
//
//  Created by Tamas Attila Horvath on 2019. 11. 10..
//  Copyright © 2019. Tomi. All rights reserved.
//

@testable import FlightRider
import UIKit
import XCTest

class LoginPresenterTests: XCTestCase
{
    // MARK: - Subject under test
    
    var sut: LoginPresenter!
    
    // MARK: - Test lifecycle
    
    override func setUp()
    {
        super.setUp()
        setupLoginPresenter()
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    // MARK: - Test setup
    
    func setupLoginPresenter()
    {
        sut = LoginPresenter()
    }
    
    class LoginDisplayLogicMock: LoginDisplayLogic
    {
        
        var requestLoginDataCalled = false
        var displayLoginDataCalled = false
        var pushRememberMeSwitchChangedCalled = false
        var setLoginErrorCalled = false
        var setRememberMeOnCalled = false
        var setRememberMeOffCalled = false
        var setRemoveSpinnerCalled = false
        var routeToFlightListCalled = false
        
        func requestLoginData() {
            requestLoginDataCalled = true
        }
        
        func displayLoginData(viewModel: Login.LoginFields.ViewModel) {
            displayLoginDataCalled = true
        }
        
        func pushRememberMeSwitchChanged() {
            pushRememberMeSwitchChangedCalled = true
        }
        
        func setLoginError() {
            setLoginErrorCalled = true
        }
        
        func setRememberMeOn() {
            setRememberMeOnCalled = true
        }
        
        func setRememberMeOff() {
            setRememberMeOffCalled = true
        }
        
        func setRemoveSpinner() {
            setRemoveSpinnerCalled = true
        }
        
        func routeToFlightList(response: Login.LoginProcess.Response) {
            routeToFlightListCalled = true
        }
        
    }
    
    func testFetchSignupAuthenticationResultsTrue()
    {
        // Given
        let loginDisplayLogicMock = LoginDisplayLogicMock()
        sut.viewController = loginDisplayLogicMock
        
        // When
        let response = Login.SignupProcess.Response(email: "dummy", uid: "dummy", databaseWorker: nil, success: true)
        sut.fetchSignupAuthenticationResults(response: response)
        
        // Then
        XCTAssert(loginDisplayLogicMock.routeToFlightListCalled == true && loginDisplayLogicMock.setLoginErrorCalled == false)
    }
    
    func testFetchSignupAuthenticationResultsFalse()
    {
        // Given
        let loginDisplayLogicMock = LoginDisplayLogicMock()
        sut.viewController = loginDisplayLogicMock
        
        // When
        let response = Login.SignupProcess.Response(email: "dummy", uid: "dummy", databaseWorker: nil, success: false)
        sut.fetchSignupAuthenticationResults(response: response)
        
        // Then
        XCTAssert(loginDisplayLogicMock.routeToFlightListCalled == false && loginDisplayLogicMock.setLoginErrorCalled == true)
    }
    
    func testFetchLoginDataTrue(){
        //Given
        let loginDisplayLogicMock = LoginDisplayLogicMock()
        sut.viewController = loginDisplayLogicMock
        
        //When
        let response = Login.LoginFields.Response(email: "dummy", password: "dummy", switchedOn: true)
        sut.fetchLoginData(response: response)
        
        //Then
        XCTAssert(loginDisplayLogicMock.setRememberMeOnCalled == true &&
            loginDisplayLogicMock.setRememberMeOffCalled == false &&
            loginDisplayLogicMock.displayLoginDataCalled == true)
    }
    
    func testFetchLoginDataFalse(){
        //Given
        let loginDisplayLogicMock = LoginDisplayLogicMock()
        sut.viewController = loginDisplayLogicMock
        
        //When
        let response = Login.LoginFields.Response(email: "dummy", password: "dummy", switchedOn: false)
        sut.fetchLoginData(response: response)
        
        //Then
        XCTAssert(loginDisplayLogicMock.setRememberMeOnCalled == false &&
            loginDisplayLogicMock.setRememberMeOffCalled == true &&
            loginDisplayLogicMock.displayLoginDataCalled == true)
    }
}

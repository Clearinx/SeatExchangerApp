//
//  LoginInteractorTests.swift
//  FlightRiderTests
//
//  Created by Tamas Attila Horvath on 2019. 11. 10..
//  Copyright © 2019. Tomi. All rights reserved.
//

@testable import FlightRider
import UIKit
import XCTest
import CloudKit

class LoginInteractorTests: XCTestCase{
    
    // MARK: - Subject under test
    
    var sut: LoginInteractor!
    
    // MARK: - Test lifecycle
    
    override func setUp()
    {
        super.setUp()
        setupLoginInteractor()
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    // MARK: - Test setup
    
    func setupLoginInteractor()
    {
        sut = LoginInteractor()
    }
    
    class LoginPresentationLogicMock: LoginPresentationLogic
    {
        
        var fetchLoginDataCalled = false
        var fetchLoginProcessResultsCalled = false
        var fetchSignupAuthenticationResultsCalled = false
        var setLoginErrorCalled = false
        
        var loginProcessResults : Login.LoginProcess.Response!
        
        func fetchLoginData(response: Login.LoginFields.Response) {
            fetchLoginDataCalled = true
        }
        
        func fetchLoginProcessResults(response: Login.LoginProcess.Response) {
            fetchLoginProcessResultsCalled = true
            loginProcessResults = response
        }
        
        func fetchSignupAuthenticationResults(response: Login.SignupProcess.Response) {
            fetchSignupAuthenticationResultsCalled = true
        }
        
        func setLoginError() {
            setLoginErrorCalled = true
        }

    }
    
    class LoginWorkerMock : LoginWorkerProtocol
    {
        
        weak var interactor: LoginBusinessLogic?
        
        var requestLoginDataCalled = false
        var requestLoginAuthenticationCalled = false
        var requestSignupAuthenticationCalled = false
        var pushSwitchOffRememberMeCalled = false
        var pushSwitchOnRememberMeCalled = false
        var pushLoginDataUpdateCalled = false
        var saveRecordsCalled = false
        
        
        func requestLoginData(request: Login.LoginFields.Request) {
            requestLoginDataCalled = true
        }
        
        func requestLoginAuthentication(request: Login.LoginProcess.Request) {
            requestLoginAuthenticationCalled = true
        }
        
        func requestSignupAuthentication(request: Login.SignupProcess.Request) {
            requestSignupAuthenticationCalled = true
        }
        
        func pushSwitchOffRememberMe() {
            pushSwitchOffRememberMeCalled = true
        }
        
        func pushSwitchOnRememberMe(request: Login.SwitchData.Request) {
            pushSwitchOnRememberMeCalled = true
        }
        
        func pushLoginDataUpdate(request: Login.LoginProcess.Request) {
            pushLoginDataUpdateCalled = true
        }
        
        func saveRecords(records: [CKRecord]) {
            saveRecordsCalled = true
        }
        
        
    }
    
    func testRequestLoginDataUpdateEmailNotNilSwitchOn(){
        // Given
        let loginPresentationLogicMock = LoginPresentationLogicMock()
        let loginWorkerMock = LoginWorkerMock()
        sut.presenter = loginPresentationLogicMock
        sut.worker = loginWorkerMock
        
        // When
        let request = Login.LoginProcess.Request(email: "dummy", password: "dummy", switchedOn: true)
        sut.requestLoginDataUpdate(request: request)
        
        // Then
        XCTAssert(loginWorkerMock.pushLoginDataUpdateCalled == true)
    }
    
    func testRequestLoginDataUpdateEmailNilSwitchOn(){
        // Given
        let loginPresentationLogicMock = LoginPresentationLogicMock()
        let loginWorkerMock = LoginWorkerMock()
        sut.presenter = loginPresentationLogicMock
        sut.worker = loginWorkerMock
        
        // When
        let request = Login.LoginProcess.Request(email: "dummy", password: nil, switchedOn: true)
        sut.requestLoginDataUpdate(request: request)
        
        // Then
        XCTAssert(loginWorkerMock.pushLoginDataUpdateCalled == false)
    }
    
    func testRequestLoginDataUpdateEmailPwNilSwitchOn(){
        // Given
        let loginPresentationLogicMock = LoginPresentationLogicMock()
        let loginWorkerMock = LoginWorkerMock()
        sut.presenter = loginPresentationLogicMock
        sut.worker = loginWorkerMock
        
        // When
        let request = Login.LoginProcess.Request(email: nil, password: nil, switchedOn: true)
        sut.requestLoginDataUpdate(request: request)
        
        // Then
        XCTAssert(loginWorkerMock.pushLoginDataUpdateCalled == false)
    }
    
    func testRequestLoginDataUpdateEmailPwNotNilSwitchOff(){
        // Given
        let loginPresentationLogicMock = LoginPresentationLogicMock()
        let loginWorkerMock = LoginWorkerMock()
        sut.presenter = loginPresentationLogicMock
        sut.worker = loginWorkerMock
        
        // When
        let request = Login.LoginProcess.Request(email: "dummy", password: "dummy", switchedOn: false)
        sut.requestLoginDataUpdate(request: request)
        
        // Then
        XCTAssert(loginWorkerMock.pushLoginDataUpdateCalled == false)
    }
    
    func testRequestSignupAuthenticationNotNil(){
        // Given
        let loginPresentationLogicMock = LoginPresentationLogicMock()
        let loginWorkerMock = LoginWorkerMock()
        sut.presenter = loginPresentationLogicMock
        sut.worker = loginWorkerMock
        
        // When
        let request = Login.SignupProcess.Request(email: "dummy", password: "dummy")
        sut.requestSignupAuthentication(request: request)
        
        // Then
        XCTAssert(loginPresentationLogicMock.setLoginErrorCalled == false)
        XCTAssert(loginWorkerMock.requestSignupAuthenticationCalled == true)
    }
    
    func testRequestSignupAuthenticationEmailNil(){
        // Given
        let loginPresentationLogicMock = LoginPresentationLogicMock()
        let loginWorkerMock = LoginWorkerMock()
        sut.presenter = loginPresentationLogicMock
        sut.worker = loginWorkerMock
        
        // When
        let request = Login.SignupProcess.Request(email: nil, password: "dummy")
        sut.requestSignupAuthentication(request: request)
        
        // Then
        XCTAssert(loginPresentationLogicMock.setLoginErrorCalled == true)
        XCTAssert(loginWorkerMock.requestSignupAuthenticationCalled == false)
    }
    
    func testRequestSignupAuthenticationPwNil(){
        // Given
        let loginPresentationLogicMock = LoginPresentationLogicMock()
        let loginWorkerMock = LoginWorkerMock()
        sut.presenter = loginPresentationLogicMock
        sut.worker = loginWorkerMock
        
        // When
        let request = Login.SignupProcess.Request(email: "dummy", password: nil)
        sut.requestSignupAuthentication(request: request)
        
        // Then
        XCTAssert(loginPresentationLogicMock.setLoginErrorCalled == true)
        XCTAssert(loginWorkerMock.requestSignupAuthenticationCalled == false)
    }
    
    func testRequestSignupAuthenticationBothNil(){
        // Given
        let loginPresentationLogicMock = LoginPresentationLogicMock()
        let loginWorkerMock = LoginWorkerMock()
        sut.presenter = loginPresentationLogicMock
        sut.worker = loginWorkerMock
        
        // When
        let request = Login.SignupProcess.Request(email: nil, password: nil)
        sut.requestSignupAuthentication(request: request)
        
        // Then
        XCTAssert(loginPresentationLogicMock.setLoginErrorCalled == true)
        XCTAssert(loginWorkerMock.requestSignupAuthenticationCalled == false)
    }
    
    func testFetchLoginProcessResultsSuccedded(){
        // Given
        let loginPresentationLogicMock = LoginPresentationLogicMock()
        let loginWorkerMock = LoginWorkerMock()
        sut.presenter = loginPresentationLogicMock
        sut.worker = loginWorkerMock
        
        // When
        let response = Login.LoginProcess.Response(email: "dummy", uid: "dummy", databaseWorker: nil, success: true)
        sut.fetchLoginProcessResults(response: response)
        
        // Then
        XCTAssert(loginPresentationLogicMock.loginProcessResults.databaseWorker != nil)
    }
    
    func testFetchLoginProcessResultsFailed(){
        // Given
        let loginPresentationLogicMock = LoginPresentationLogicMock()
        let loginWorkerMock = LoginWorkerMock()
        sut.presenter = loginPresentationLogicMock
        sut.worker = loginWorkerMock
        
        // When
        let response = Login.LoginProcess.Response(email: "dummy", uid: "dummy", databaseWorker: nil, success: false)
        sut.fetchLoginProcessResults(response: response)
        
        // Then
        XCTAssert(loginPresentationLogicMock.loginProcessResults.databaseWorker == nil)
    }
    
    func testPushRememberMeSwitchChangedSwOff(){
        // Given
        let loginPresentationLogicMock = LoginPresentationLogicMock()
        let loginWorkerMock = LoginWorkerMock()
        sut.presenter = loginPresentationLogicMock
        sut.worker = loginWorkerMock
        
        // When
        let request = Login.SwitchData.Request(email: "dummy", password: "dummy", switchedOn: false)
        sut.pushRememberMeSwitchChanged(request: request)
        
        // Then
        XCTAssert(loginWorkerMock.pushSwitchOffRememberMeCalled == true)
        XCTAssert(loginWorkerMock.pushSwitchOnRememberMeCalled == false)
    }
    
    func testPushRememberMeSwitchChangedNilSwOff(){
        // Given
        let loginPresentationLogicMock = LoginPresentationLogicMock()
        let loginWorkerMock = LoginWorkerMock()
        sut.presenter = loginPresentationLogicMock
        sut.worker = loginWorkerMock
        
        // When
        let request = Login.SwitchData.Request(email: "dummy", password: nil, switchedOn: false)
        sut.pushRememberMeSwitchChanged(request: request)
        
        // Then
        XCTAssert(loginWorkerMock.pushSwitchOffRememberMeCalled == true)
        XCTAssert(loginWorkerMock.pushSwitchOnRememberMeCalled == false)
    }
    
    func testPushRememberMeSwitchChangedNilSwOn(){
        // Given
        let loginPresentationLogicMock = LoginPresentationLogicMock()
        let loginWorkerMock = LoginWorkerMock()
        sut.presenter = loginPresentationLogicMock
        sut.worker = loginWorkerMock
        
        // When
        let request = Login.SwitchData.Request(email: "dummy", password: nil, switchedOn: true)
        sut.pushRememberMeSwitchChanged(request: request)
        
        // Then
        XCTAssert(loginWorkerMock.pushSwitchOffRememberMeCalled == false)
        XCTAssert(loginWorkerMock.pushSwitchOnRememberMeCalled == false)
    }
    
    func testPushRememberMeSwitchChangedNil2SwOn(){
        // Given
        let loginPresentationLogicMock = LoginPresentationLogicMock()
        let loginWorkerMock = LoginWorkerMock()
        sut.presenter = loginPresentationLogicMock
        sut.worker = loginWorkerMock
        
        // When
        let request = Login.SwitchData.Request(email: nil, password: nil, switchedOn: true)
        sut.pushRememberMeSwitchChanged(request: request)
        
        // Then
        XCTAssert(loginWorkerMock.pushSwitchOffRememberMeCalled == false)
        XCTAssert(loginWorkerMock.pushSwitchOnRememberMeCalled == false)
    }
    
    func testPushRememberMeSwitchChangedNotNilSwOn(){
        // Given
        let loginPresentationLogicMock = LoginPresentationLogicMock()
        let loginWorkerMock = LoginWorkerMock()
        sut.presenter = loginPresentationLogicMock
        sut.worker = loginWorkerMock
        
        // When
        let request = Login.SwitchData.Request(email: "dummy", password: "dummy", switchedOn: true)
        sut.pushRememberMeSwitchChanged(request: request)
        
        // Then
        XCTAssert(loginWorkerMock.pushSwitchOffRememberMeCalled == false)
        XCTAssert(loginWorkerMock.pushSwitchOnRememberMeCalled == true)
    }
}

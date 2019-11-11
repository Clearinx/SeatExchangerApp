//
//  LoginWorker.swift
//  FlightRiderTests
//
//  Created by Tomi on 2019. 11. 11..
//  Copyright © 2019. Tomi. All rights reserved.
//

@testable import FlightRider
import UIKit
import XCTest

class LoginWorkerTests: XCTestCase
{
    // MARK: - Subject under test
    
    var sut: LoginWorker!
    var savedUser : String!
    var savedPass : String!
    var switchState : Bool!
    
    // MARK: - Test lifecycle
    
    override func setUp()
    {
        super.setUp()
        setupLoginWorker()
    }
    
    override func tearDown()
    {
        super.tearDown()
        let defaults: UserDefaults? = UserDefaults.standard
        defaults?.set(savedUser, forKey: "SavedUserName")
        KeychainWrapper.standard.set(savedPass, forKey: "SavedPassword")
        defaults?.set(switchState, forKey: "ISRemember")
    }
    
    // MARK: - Test setup
    
    func setupLoginWorker()
    {
        sut = LoginWorker()
        
        let defaults: UserDefaults? = UserDefaults.standard
        
        switchState = (defaults?.bool(forKey: "ISRemember")) ?? false
        savedUser = defaults?.value(forKey: "SavedUserName") as? String ?? ""
        if let retrievedString = KeychainWrapper.standard.string(forKey: "SavedPassword"){
            savedPass = retrievedString
        }
    }
    
    // MARK: - Test doubles
    
    class LoginBusinessLogicSpy: LoginBusinessLogic{
        
        var requestLoginDataCalledCalled = false
        var requestLoginDataUpdateCalled = false
        var requestLoginAuthenticationCalled = false
        var requestSignupAuthenticationCalled = false
        var fetchLoginDataCalled = false
        var fetchLoginProcessResultsCalled = false
        var fetchSignupAuthenticationResultsCalled = false
        var pushRememberMeSwitchChangedCalled = false
        
        var requestLoginDataResponse = Login.LoginFields.Response()
        
        func requestLoginData(request: Login.LoginFields.Request) {
            requestLoginDataCalledCalled = true
        }
        
        func requestLoginDataUpdate(request: Login.LoginProcess.Request) {
            requestLoginDataUpdateCalled = true
        }
        
        func requestLoginAuthentication(request: Login.LoginProcess.Request) {
            requestLoginAuthenticationCalled = true
        }
        
        func requestSignupAuthentication(request: Login.SignupProcess.Request) {
            requestSignupAuthenticationCalled = true
        }
        
        func fetchLoginData(response: Login.LoginFields.Response) {
            fetchLoginDataCalled = true
            requestLoginDataResponse = response
        }
        
        func fetchLoginProcessResults(response: Login.LoginProcess.Response) {
            fetchLoginProcessResultsCalled = true
        }
        
        func fetchSignupAuthenticationResults(response: Login.SignupProcess.Response) {
            fetchSignupAuthenticationResultsCalled = true
        }
        
        func pushRememberMeSwitchChanged(request: Login.SwitchData.Request) {
            pushRememberMeSwitchChangedCalled = true
        }
        
    }
    
    func testRequestLoginDataSwTrueEmailPwNotNil()
    {
        // Given
        let loginBusinessLogicSpy = LoginBusinessLogicSpy()
        sut.interactor = loginBusinessLogicSpy
        
        // When
        let defaults: UserDefaults? = UserDefaults.standard
        defaults?.set(true, forKey: "ISRemember")
        defaults?.set("DummyName", forKey: "SavedUserName")
        KeychainWrapper.standard.set("DummyPass", forKey: "SavedPassword")
        
        let request = Login.LoginFields.Request()
        sut.requestLoginData(request: request)
        
        // Then
        XCTAssert(loginBusinessLogicSpy.requestLoginDataResponse.switchedOn == true)
        XCTAssert(loginBusinessLogicSpy.requestLoginDataResponse.email == "DummyName")
        XCTAssert(loginBusinessLogicSpy.requestLoginDataResponse.password == "DummyPass")
    }
    
    func testRequestLoginDataSwFalseEmailPwNotNil()
    {
        // Given
        let loginBusinessLogicSpy = LoginBusinessLogicSpy()
        sut.interactor = loginBusinessLogicSpy
        
        // When
        let defaults: UserDefaults? = UserDefaults.standard
        defaults?.set(false, forKey: "ISRemember")
        defaults?.set("DummyName", forKey: "SavedUserName")
        KeychainWrapper.standard.set("DummyPass", forKey: "SavedPassword")
        
        let request = Login.LoginFields.Request()
        sut.requestLoginData(request: request)
        
        // Then
        XCTAssert(loginBusinessLogicSpy.requestLoginDataResponse.switchedOn == false)
        XCTAssert(loginBusinessLogicSpy.requestLoginDataResponse.email == nil)
        XCTAssert(loginBusinessLogicSpy.requestLoginDataResponse.password == nil)
    }
    
    func testRequestLoginDataSwnilEmaNilPwNotNil()
    {
        // Given
        let loginBusinessLogicSpy = LoginBusinessLogicSpy()
        sut.interactor = loginBusinessLogicSpy
        
        // When
        let defaults: UserDefaults? = UserDefaults.standard
        defaults?.set(nil, forKey: "ISRemember")
        defaults?.set(nil, forKey: "SavedUserName")
        KeychainWrapper.standard.set("DummyPass", forKey: "SavedPassword")
        
        let request = Login.LoginFields.Request()
        sut.requestLoginData(request: request)
        
        // Then
        XCTAssert(loginBusinessLogicSpy.requestLoginDataResponse.switchedOn == false)
        XCTAssert(loginBusinessLogicSpy.requestLoginDataResponse.email == nil)
        XCTAssert(loginBusinessLogicSpy.requestLoginDataResponse.password == nil)
    }
    
    func testRequestLoginDataSwnilEmailNotNilPwNotNil()
    {
        // Given
        let loginBusinessLogicSpy = LoginBusinessLogicSpy()
        sut.interactor = loginBusinessLogicSpy
        
        // When
        let defaults: UserDefaults? = UserDefaults.standard
        defaults?.set(nil, forKey: "ISRemember")
        defaults?.set("DummyName", forKey: "SavedUserName")
        KeychainWrapper.standard.set("DummyPass", forKey: "SavedPassword")
        
        let request = Login.LoginFields.Request()
        sut.requestLoginData(request: request)
        
        // Then
        XCTAssert(loginBusinessLogicSpy.requestLoginDataResponse.switchedOn == false)
        XCTAssert(loginBusinessLogicSpy.requestLoginDataResponse.email == nil)
        XCTAssert(loginBusinessLogicSpy.requestLoginDataResponse.password == nil)
    }
    
    func testRequestLoginDataSwTrueEmailNilPwNotNil()
    {
        // Given
        let loginBusinessLogicSpy = LoginBusinessLogicSpy()
        sut.interactor = loginBusinessLogicSpy
        
        // When
        let defaults: UserDefaults? = UserDefaults.standard
        defaults?.set(true, forKey: "ISRemember")
        defaults?.set(nil, forKey: "SavedUserName")
        KeychainWrapper.standard.set("DummyPass", forKey: "SavedPassword")
        
        let request = Login.LoginFields.Request()
        sut.requestLoginData(request: request)
        
        // Then
        XCTAssert(loginBusinessLogicSpy.requestLoginDataResponse.switchedOn == true)
        XCTAssert(loginBusinessLogicSpy.requestLoginDataResponse.email == "")
        XCTAssert(loginBusinessLogicSpy.requestLoginDataResponse.password == "DummyPass")
    }
    
    func testpushSwitchOffRememberMe(){
        // Given
        let loginBusinessLogicSpy = LoginBusinessLogicSpy()
        sut.interactor = loginBusinessLogicSpy
        
        // When
        let defaults: UserDefaults? = UserDefaults.standard
        defaults?.set(true, forKey: "ISRemember")
        
        sut.pushSwitchOffRememberMe()
        
        // Then
        XCTAssert(defaults?.bool(forKey: "ISRemember") == false)
    }
    
    func testpushSwitchOffRememberMeSwOff(){
        // Given
        let loginBusinessLogicSpy = LoginBusinessLogicSpy()
        sut.interactor = loginBusinessLogicSpy
        
        // When
        let defaults: UserDefaults? = UserDefaults.standard
        defaults?.set(false, forKey: "ISRemember")
        
        sut.pushSwitchOffRememberMe()
        
        // Then
        XCTAssert(defaults?.bool(forKey: "ISRemember") == false)
    }
    
    func testpushSwitchOnRememberMe(){
        // Given
        let loginBusinessLogicSpy = LoginBusinessLogicSpy()
        sut.interactor = loginBusinessLogicSpy
        
        // When
        let defaults: UserDefaults? = UserDefaults.standard
        defaults?.set(false, forKey: "ISRemember")
        
        let request = Login.SwitchData.Request(email: "Dummy", password: "Dummy", switchedOn: false)
        sut.pushSwitchOnRememberMe(request: request)
        
        // Then
        XCTAssert(defaults?.bool(forKey: "ISRemember") == true)
    }
    
    func testpushSwitchOnRememberMeSwOn(){
        // Given
        let loginBusinessLogicSpy = LoginBusinessLogicSpy()
        sut.interactor = loginBusinessLogicSpy
        
        // When
        let defaults: UserDefaults? = UserDefaults.standard
        defaults?.set(true, forKey: "ISRemember")
        
        let request = Login.SwitchData.Request(email: "Dummy", password: "Dummy", switchedOn: true)
        sut.pushSwitchOnRememberMe(request: request)
        
        // Then
        XCTAssert(defaults?.bool(forKey: "ISRemember") == true)
    }
    
    func testPushLoginDataUpdate(){
        // Given
        let loginBusinessLogicSpy = LoginBusinessLogicSpy()
        sut.interactor = loginBusinessLogicSpy
        
        // When
        let defaults: UserDefaults? = UserDefaults.standard
        defaults?.set("NotDummy", forKey: "SavedUserName")
        KeychainWrapper.standard.set("DummyPass", forKey: "SavedPassword")
        
        let request = Login.LoginProcess.Request(email: "Dummy", password: "Dummy", switchedOn: true)
        sut.pushLoginDataUpdate(request: request)
        
        // Then
        XCTAssert(defaults?.value(forKey: "SavedUserName") as? String == "Dummy")
        XCTAssert(KeychainWrapper.standard.string(forKey: "SavedPassword") == "Dummy")
        
    }
    
    func testPushLoginDataUpdatePwSame(){
        // Given
        let loginBusinessLogicSpy = LoginBusinessLogicSpy()
        sut.interactor = loginBusinessLogicSpy
        
        // When
        let defaults: UserDefaults? = UserDefaults.standard
        defaults?.set("NotDummy", forKey: "SavedUserName")
        KeychainWrapper.standard.set("Dummy", forKey: "SavedPassword")
        
        let request = Login.LoginProcess.Request(email: "Dummy", password: "Dummy", switchedOn: true)
        sut.pushLoginDataUpdate(request: request)
        
        // Then
        XCTAssert(defaults?.value(forKey: "SavedUserName") as? String == "Dummy")
        XCTAssert(KeychainWrapper.standard.string(forKey: "SavedPassword") == "Dummy")
        
    }
    
    func testPushLoginDataUpdateUserSame(){
        // Given
        let loginBusinessLogicSpy = LoginBusinessLogicSpy()
        sut.interactor = loginBusinessLogicSpy
        
        // When
        let defaults: UserDefaults? = UserDefaults.standard
        defaults?.set("Dummy", forKey: "SavedUserName")
        KeychainWrapper.standard.set("NotDummy", forKey: "SavedPassword")
        
        let request = Login.LoginProcess.Request(email: "Dummy", password: "Dummy", switchedOn: true)
        sut.pushLoginDataUpdate(request: request)
        
        // Then
        XCTAssert(defaults?.value(forKey: "SavedUserName") as? String == "Dummy")
        XCTAssert(KeychainWrapper.standard.string(forKey: "SavedPassword") == "Dummy")
        
    }
    
    func testPushLoginDataUpdateUserNil(){
        // Given
        let loginBusinessLogicSpy = LoginBusinessLogicSpy()
        sut.interactor = loginBusinessLogicSpy
        
        // When
        let defaults: UserDefaults? = UserDefaults.standard
        defaults?.set(nil, forKey: "SavedUserName")
        KeychainWrapper.standard.set("NotDummy", forKey: "SavedPassword")
        
        let request = Login.LoginProcess.Request(email: "Dummy", password: "Dummy", switchedOn: true)
        sut.pushLoginDataUpdate(request: request)
        
        // Then
        XCTAssert(defaults?.value(forKey: "SavedUserName") as? String == "Dummy")
        XCTAssert(KeychainWrapper.standard.string(forKey: "SavedPassword") == "Dummy")
        
    }
    
}



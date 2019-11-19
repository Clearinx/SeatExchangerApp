//
//  LoginViewControllerTests.swift
//  FlightRiderTests
//
//  Created by Tomi on 2019. 11. 11..
//  Copyright © 2019. Tomi. All rights reserved.
//

@testable import FlightRider
import UIKit
import XCTest

class LoginViewControllerTests: XCTestCase {
    // MARK: - Subject under test

    var sut: LoginViewController!

    // MARK: - Test lifecycle

    override func setUp() {
        super.setUp()
        setupLoginWorker()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Test setup

    func setupLoginWorker() {
        sut = LoginViewController()
    }

    // MARK: - Test doubles

    class LoginBusinessLogicSpy: LoginBusinessLogic {

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
}

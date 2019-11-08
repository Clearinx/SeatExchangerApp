//
//  CannotCheckInInteractor.swift
//  FlightRider
//
//  Created by Tomi on 2019. 10. 31..
//  Copyright (c) 2019. Tomi. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol CannotCheckInBusinessLogic
{
    func requestRemaningTimeCalculation(request: CannotCheckIn.CalculateTime.Request)
    func requestStoredData(request: CannotCheckIn.StoredData.Request)
    func pushDataFromPreviousViewController(viewModel: ListFlights.CannotCheckinData.ViewModel)
}

    protocol CannotCheckInDataStore
    {
        var viewModel : CannotCheckIn.StoredData.ViewModel { get set }
    }

class CannotCheckInInteractor: CannotCheckInBusinessLogic, CannotCheckInDataStore
{
  
    var presenter: CannotCheckInPresentationLogic?
    var worker: CannotCheckInWorker?
    
    var viewModel = CannotCheckIn.StoredData.ViewModel()
    
    //MARK: - Request functions
    
    func requestRemaningTimeCalculation(request: CannotCheckIn.CalculateTime.Request) {
        presenter?.requestRemaningTimeCalculation(request: request)
    }
    
    func requestStoredData(request: CannotCheckIn.StoredData.Request) {
        let response = CannotCheckIn.StoredData.Response(iataNumber: viewModel.iataNumber, departureDate: viewModel.departureDate, image: viewModel.image)
        presenter?.fetchStoredData(response: response)
    }
    
    //MARK: - Push functions
    
    func pushDataFromPreviousViewController(viewModel: ListFlights.CannotCheckinData.ViewModel) {
         self.viewModel.iataNumber = viewModel.iataNumber
         self.viewModel.departureDate = viewModel.departureDate
         self.viewModel.image = viewModel.imageToLoad
    }
}
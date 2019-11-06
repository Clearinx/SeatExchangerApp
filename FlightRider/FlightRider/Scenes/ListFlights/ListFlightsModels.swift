//
//  ListFlightsModels.swift
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
import CloudKit

enum ListFlights
{
    enum CannotCheckinData
    {
        struct Request
        {
        }
        struct Response
        {
        }
        struct ViewModel
        {
            var iataNumber : String
            var departureDate : Date
            var imageToLoad: UIImage?
        }
    }
    
    enum CheckSeatsData
    {
        struct Request
        {
        }
        struct Response
        {
        }
        struct DataStore
        {
            let flight : ManagedFlight
            let user : ManagedUser
            let justSelectedSeat : Bool
        }
    }
    
    enum DataStore
    {
        struct Request
        {
        }
        struct Response
        {
        }
        struct Results
        {
            var localUser : ManagedUser?
            var cloudUser : CloudUser?
        }
        struct DataStore
        {
            var uid: String!
            var email: String!
            var user : ManagedUser?
            var flights : [ManagedFlight]!
            var userRecord : CloudUser!
        }
    }
    
    enum SelectSeatsData
    {
        struct Request
        {
        }
        struct Response
        {
        }
        struct ViewModel
        {
            let flight : ManagedFlight
            let user : ManagedUser
            let userRecord : CKRecord
            let image : UIImage?
            let databaseWorker : DatabaseWorker
        }
    }
    
    enum UserData
    {
        struct EmptyRequest
        {
        }
        struct Request
        {
            var userUid : String!
            var userEmail : String!
            
        }
        struct Response
        {
        }
        struct ViewModel
        {
        }
    }
}

//
//  SelectSeatsModels.swift
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

enum SelectSeats
{
  // MARK: Use cases
  
  enum StoredData
  {
    struct Request
    {
    }
    struct Response
    {
        var flight : ManagedFlight?
        var user : ManagedUser?
        var userRecord : CKRecord?
        var image : UIImage?
    }
    struct ViewModel
    {
        var flight : ManagedFlight?
        var user : ManagedUser?
        var userRecord : CKRecord?
        var image : UIImage?
    }
    
    
  }
    
    enum DisplayData
    {
        struct Request
        {
        }
        struct Response
        {
            var image: UIImage?
            var flightNumber : String?
        }
        struct ViewModel
        {
            var image: UIImage?
            var flightNumber : String?
        }
        
        
    }
}

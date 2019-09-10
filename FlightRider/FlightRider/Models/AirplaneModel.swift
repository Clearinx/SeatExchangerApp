//
//  AirplaneModel.swift
//  FlightRider
//
//  Created by Tomi on 2019. 09. 09..
//  Copyright © 2019. Tomi. All rights reserved.
//

import Foundation

struct AirplaneModel{
    var modelName : String
    var numberOfSeats : Int
    var columns : String
    
    init(modelName: String, numberOfSeats: Int, latestColumn: String) {
        self.modelName = modelName
        self.numberOfSeats = numberOfSeats
        self.columns = latestColumn
    }
}

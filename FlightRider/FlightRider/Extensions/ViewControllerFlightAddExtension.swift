//
//  ViewControllerFlightAddExtension.swift
//  FlightRider
//
//  Created by Tomi on 2019. 10. 17..
//  Copyright © 2019. Tomi. All rights reserved.
//

import Foundation
import CloudKit
import CoreData


extension ViewController
{
    func saveFlightDataToBothDbAppendToFlightList(params: [String]?){ //flight validity check disabled for testing
        let flightCode = params![0]
        let departureDate = params![1]
        let airlineIata = flightCode.prefix(2)
        let flightNumber = flightCode.suffix(flightCode.count-2)
        /*let results = [flightCode, "\(departureDate)  11:20:00"]
         saveFlightDataToBothDb(params: results)*/
        let urlString = "https://aviation-edge.com/v2/public/routes?key=ee252d-c24759&airlineIata=\(airlineIata)&flightNumber=\(flightNumber)"
        do{
            let data = try String(contentsOf: URL(string: urlString)!)
            let jsonData = JSON(parseJSON: data)
            let jsonArray = jsonData.arrayValue
            if (!(jsonArray.isEmpty)){
                let results = self.createStringsFromJson(json : jsonArray[0], flightCode: flightCode, departureDate: departureDate)
                saveFlightDataToBothDb(params: results)
                
            }
            else{
                flightNotFoundError()
            }
            
        }
        catch{
            flightNotFoundError()
            
        }
    }
    
    func fetchFlightsFromCloudAndAppendToUserList(results : [CKRecord]){
        fetchFlightsFromCloudWaitForResult(results: results){ flight in
            self.user.flights = self.userRecord["flights"]!
            self.user.flights.append(flight.uid)
            self.userRecord["flights"] = self.user.flights as CKRecordValue
            self.saveRecords(records: [self.userRecord]){ [unowned self] in
                self.user.changetag = self.userRecord.recordChangeTag!
                self.saveContext(container: self.container)
            }
        }
    }
    
    func compareFlightsChangeTagAndAppendToUserList(localResults : [NSManagedObject],  cloudResults : [CKRecord]){
        compareFlightsChangeTagWaitForResult(localResults: localResults, cloudResults: cloudResults){
            self.user.flights = self.userRecord["flights"]!
            self.user.flights.append(cloudResults.first!["uid"]!)
            self.userRecord["flights"] = self.user.flights as CKRecordValue
            self.saveRecords(records: [self.userRecord]){ [unowned self] in
                self.user.changetag = self.userRecord.recordChangeTag!
                self.saveContext(container: self.container)
            }
        }
    }
}


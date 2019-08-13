//
//  FlightDetailViewController.swift
//  FlightRider
//
//  Created by Horvath Tamas on 2019. 07. 28..
//  Copyright © 2019. Tomi. All rights reserved.
//

import UIKit
import CoreData

class FlightDetailViewController: UIViewController {

    @IBOutlet weak var flightNr: UILabel!
    @IBOutlet weak var flightLogo: UIImageView!
    
    
    
    var flightNrString : String?
    var imageToLoad : UIImage!
    var container: NSPersistentContainer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if flightNrString != nil{
            flightNr.text = flightNrString
            flightLogo.image = imageToLoad
        }
        
        container = NSPersistentContainer(name: "FlightRider")
        
        container.loadPersistentStores { storeDescription, error in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
        
        let flight = Flight(context: self.container.viewContext)
        flight.iataNumber = "FR110"
        flight.departureDate = Date()
        flight.checkedIn = true
        
        let seat = Seat(context: self.container.viewContext)
        seat.number = "13C"
        seat.occupiedBy = "AAA"
        
        flight.seats = [seat]

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

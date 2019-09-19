//
//  FlightDetailViewControllerCannotCheckin.swift
//  FlightRider
//
//  Created by Tomi on 2019. 08. 02..
//  Copyright © 2019. Tomi. All rights reserved.
//

import UIKit

class FlightDetailViewControllerCannotCheckin: UIViewController {
    

    @IBOutlet weak var flightNr: UILabel!
    @IBOutlet weak var flightLogo: UIImageView!
    @IBOutlet weak var timeLeft: UILabel!
    
    var flightNrString : String?
    var imageToLoad : UIImage!
    var departureDate : Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        flightNr.text = flightNrString
        flightLogo.image = imageToLoad
        let deltaTime = Calendar.current.date(byAdding: .day, value:-2, to: departureDate)! - Date()
        let timeResult = convertToDaysHoursMinutes(interval: deltaTime)
        timeLeft.text = "\(timeResult.days) days \(timeResult.hours) hours \(timeResult.minutes) minutes"
        
        // Do any additional setup after loading the view.
    }
    
    func convertToDaysHoursMinutes(interval: TimeInterval) -> Time{
        let daysFraction = interval / 86400
        let days = Double(Int(daysFraction))
        let hoursFraction = (daysFraction - days) * 24
        let hours = Double(Int(hoursFraction))
        let minutesFraction = (hoursFraction - hours) * 60
        let minutes = Int(minutesFraction)
        return Time(days: String(Int(days)), hours: String(Int(hours)), minutes: String(minutes))
    }
    


}

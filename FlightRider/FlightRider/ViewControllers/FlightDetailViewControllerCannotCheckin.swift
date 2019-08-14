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
    
    var flightNrString : String?
    var imageToLoad : UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if flightNrString != nil{
            flightNr.text = flightNrString
            flightLogo.image = imageToLoad
        }
        
        // Do any additional setup after loading the view.
    }
    


}

//
//  FlightDetailViewController.swift
//  FlightRider
//
//  Created by Horvath Tamas on 2019. 07. 28..
//  Copyright © 2019. Tomi. All rights reserved.
//

import UIKit

class FlightDetailViewController: UIViewController {

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

    }

}

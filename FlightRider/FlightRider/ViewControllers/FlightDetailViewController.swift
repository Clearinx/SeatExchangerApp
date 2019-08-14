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

//
//  FlightDetailViewControllerExchangeAggreement.swift
//  FlightRider
//
//  Created by Tomi on 2019. 08. 08..
//  Copyright © 2019. Tomi. All rights reserved.
//

import UIKit

class FlightDetailViewControllerExchangeAggreement: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var flightLogo: UIImageView!
    @IBOutlet weak var seat1Picker: UIPickerView!
    @IBOutlet weak var seat2Picker: UIPickerView!
    @IBOutlet weak var flightNr: UILabel!
    @IBOutlet weak var seatsToExchange: UILabel!
    @IBOutlet weak var one: UILabel!
    @IBOutlet weak var Seat1: UILabel!
    @IBOutlet weak var yourSeat: UILabel!
    @IBOutlet weak var otherSeat: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    
    var flightNrString : String?
    var imageToLoad : UIImage!
    var pickerData: [String] = [String]()
    var pickerData2: [String] = [String]()
    private let maxElements = 10000
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if flightNrString != nil{
            flightNr.text = flightNrString
            flightLogo.image = imageToLoad
        }
        pickerData = ["05F", "13C", "32A"]
        pickerData2 = ["08D", "28B", "17E"]
        seat1Picker.delegate = self
        seat1Picker.dataSource = self
        seat1Picker.selectRow((maxElements / 2) - 8, inComponent: 0, animated: false)
        seat2Picker.delegate = self
        seat2Picker.dataSource = self
        seat2Picker.selectRow((maxElements / 2) - 8, inComponent: 0, animated: false)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return maxElements
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Helvetica", size: 30)
            pickerLabel?.textAlignment = .center
        }
        if pickerView.tag == 0{
            let myRow = row % pickerData.count
            pickerLabel?.text = pickerData[myRow]
            
        }
        else if pickerView.tag == 1{
            let myRow = row % pickerData2.count
            pickerLabel?.text = pickerData2[myRow]
            
        }
        pickerLabel?.textColor = UIColor.blue
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40 // you can calculate this based on your container view or window size
    }
    
    /*func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 60
    }*/
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

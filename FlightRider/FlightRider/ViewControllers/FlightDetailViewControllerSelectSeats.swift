//
//  FlightDetailViewControllerSelectSeats.swift
//  FlightRider
//
//  Created by Tomi on 2019. 08. 02..
//  Copyright © 2019. Tomi. All rights reserved.
//

import UIKit
import CloudKit

class FlightDetailViewControllerSelectSeats: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var flightNr: UILabel!
    @IBOutlet weak var flightLogo: UIImageView!
    @IBOutlet weak var seat1Picker: UIPickerView!
    
    var pickerData: [[String]] = [[String]]()
    var pickerDataNumbers : [String] = [String]()
    var imageToLoad : UIImage!
    let maxElements = 10000
    var selectedSeatNumber : String?
    
    var flight : Flight!
    var user : User!
    var userRecord : CKRecord!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flightNr.text = flight.iataNumber
        flightLogo.image = imageToLoad
        
        for i in 1...32{
            pickerDataNumbers.append((String(format: "%02d", i)))
        }
        pickerData = [pickerDataNumbers, ["A", "B", "C", "D", "E", "F"]]
        
        seat1Picker.delegate = self
        seat1Picker.dataSource = self
        seat1Picker.selectRow((maxElements / 2) - 8, inComponent: 0, animated: false)
        seat1Picker.selectRow((maxElements / 2) - 2, inComponent: 1, animated: false)
        selectedSeatNumber = "\(pickerData[0][seat1Picker.selectedRow(inComponent: 0) % pickerData[0].count])\(pickerData[1][seat1Picker.selectedRow(inComponent: 1) % pickerData[1].count])"
    
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return maxElements
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Helvetica", size: 35)
            pickerLabel?.textAlignment = .center
        }
        let myRow = row % pickerData[component].count
        pickerLabel?.text = pickerData[component][myRow]
        //pickerLabel?.textColor = UIColor.blue
        
        return pickerLabel!
    }
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50 // you can calculate this based on your container view or window size
    }
    
    /*func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 50
    }*/
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedSeatNumber = "\(pickerData[0][pickerView.selectedRow(inComponent: 0) % pickerData[0].count])\(pickerData[1][pickerView.selectedRow(inComponent: 1) % pickerData[1].count])"
    }
    
    @IBAction func updateSeats(_ sender: Any) {
        
    }
    

    

    
}

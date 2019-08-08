//
//  FlightDetailViewControllerSelectSeats.swift
//  FlightRider
//
//  Created by Tomi on 2019. 08. 02..
//  Copyright © 2019. Tomi. All rights reserved.
//

import UIKit

class FlightDetailViewControllerSelectSeats: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var flightNr: UILabel!
    @IBOutlet weak var flightLogo: UIImageView!
    @IBOutlet weak var seat1Picker: UIPickerView!
    @IBOutlet weak var seat2Picker: UIPickerView!
    
    var pickerData: [[String]] = [[String]]()
    var pickerDataNumbers : [String] = [String]()
    var flightNrString : String?
    var imageToLoad : UIImage!
    private let maxElements = 10000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if flightNrString != nil{
            flightNr.text = flightNrString
            flightLogo.image = imageToLoad
        }
        
        for i in 1...32{
            pickerDataNumbers.append((String(format: "%02d", i)))
        }
        pickerData = [pickerDataNumbers, ["A", "B", "C", "D", "E", "F"]]
        
        seat1Picker.delegate = self
        seat1Picker.dataSource = self
        seat1Picker.selectRow((maxElements / 2) - 8, inComponent: 0, animated: false)
        seat1Picker.selectRow((maxElements / 2) - 2, inComponent: 1, animated: false)
        seat2Picker.delegate = self
        seat2Picker.dataSource = self
        seat2Picker.selectRow((maxElements / 2) - 8, inComponent: 0, animated: false)
        seat2Picker.selectRow((maxElements / 2) - 2, inComponent: 1, animated: false)
    
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
            pickerLabel?.font = UIFont(name: "Helvetica", size: 60)
            pickerLabel?.textAlignment = .center
        }
        let myRow = row % pickerData[component].count
        pickerLabel?.text = pickerData[component][myRow]
        pickerLabel?.textColor = UIColor.blue
        
        return pickerLabel!
    }
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 80 // you can calculate this based on your container view or window size
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 80
    }
    /*func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let myRow = row % pickerData[component].count
        let myString = pickerData[component][myRow]
        let myTitle = NSAttributedString(string: myString, attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia", size: 70.0)!,NSAttributedString.Key.foregroundColor:UIColor.blue])
        return myTitle
    }*/
    
    

    

    
}

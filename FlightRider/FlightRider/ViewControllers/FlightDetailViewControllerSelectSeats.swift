//
//  FlightDetailViewControllerSelectSeats.swift
//  FlightRider
//
//  Created by Tomi on 2019. 08. 02..
//  Copyright © 2019. Tomi. All rights reserved.
//

import UIKit
import CloudKit
import CoreData

class FlightDetailViewControllerSelectSeats: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var flightNr: UILabel!
    @IBOutlet weak var flightLogo: UIImageView!
    @IBOutlet weak var seat1Picker: UIPickerView!
    
    var pickerData: [[String]] = [[String]]()
    var pickerDataNumbers : [String] = [String]()
    var imageToLoad : UIImage!
    let maxElements = 10000
    var selectedSeatNumber : String?
    var container: NSPersistentContainer!
    
    var flight : Flight!
    var user : User!
    var userRecord : CKRecord!
    var justSelectedSeat : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(proceedToCheckSeats))
        
        flightNr.text = flight.iataNumber
        flightLogo.image = imageToLoad
        
        let path = Bundle.main.path(forResource: "AirplaneModels", ofType: "json")!
        let data = try? String(contentsOf: URL(fileURLWithPath: path))
        let jsonData = JSON(parseJSON: data!)
        let jsonArray = jsonData.arrayValue
        
        let jsonValue = jsonArray.filter{$0["modelName"].stringValue == self.flight.airplaneType}.first!
        let actualType = AirplaneModel(modelName: jsonValue["modelName"].stringValue, numberOfSeats: jsonValue["numberOfSeats"].intValue, latestColumn: jsonValue["columns"].stringValue)
        
        for i in 1...actualType.numberOfSeats{
            pickerDataNumbers.append((String(format: "%02d", i)))
        }
        
        let charArr : [Character] = Array(actualType.columns)
        var strArr = [String]()
        for char in charArr{
            strArr.append(String(char))
        }
        pickerData = [pickerDataNumbers, strArr]
        
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
        makeCloudQuery(sortKey: "iataNumber", predicate: NSPredicate(format: "iataNumber = %@", flight.iataNumber), cloudTable: "Flights"){ [unowned self] flightResults in
            let cloudFlight = flightResults.first!
            
            let seatRecord = CKRecord(recordType: "Seat")
            seatRecord["number"] = self.selectedSeatNumber! as CKRecordValue
            seatRecord["occupiedBy"] = self.user.email as CKRecordValue
            seatRecord["flight"] = CKRecord.Reference(recordID: cloudFlight.recordID, action: .none)
                
            var existingSeats = cloudFlight["seats"] as? [CKRecord.Reference] ?? [CKRecord.Reference]()
            existingSeats.append(CKRecord.Reference(recordID: seatRecord.recordID, action: .none))
            cloudFlight["seats"] = existingSeats
                
            self.saveRecords(records: [seatRecord, cloudFlight]){ [unowned self] in
                let seat = Seat(context: self.container.viewContext)
                seat.number = self.selectedSeatNumber!
                seat.occupiedBy = self.user.email
                seat.flight = self.flight
                seat.uid = seatRecord.recordID.recordName
                seat.changetag = seatRecord.recordChangeTag!
                self.flight.seats.insert(seat)
                self.saveContext(container: self.container)
            }
        }
        justSelectedSeat = true
    }
    
    @objc func proceedToCheckSeats(){
        if let vc = storyboard?.instantiateViewController(withIdentifier: "CheckSeats") as? CheckSeatsViewController{
            vc.flight = flight
            vc.user = user
            vc.justSelectedSeat = justSelectedSeat
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    

    

    
}

//
//  LoginViewController.swift
//  FlightRider
//
//  Created by Tomi on 2019. 08. 22..
//  Copyright © 2019. Tomi. All rights reserved.
//

import UIKit
import FirebaseAuth
import CloudKit
import CoreData

class LoginViewController: UIViewController {

    @IBOutlet weak var PasswordField: UITextField!
    @IBOutlet weak var EmailFiled: UITextField!
    var uid : String = ""
    var email : String = ""
    var container: NSPersistentContainer!

    override func viewDidLoad() {
        super.viewDidLoad()
        container = setupContainer()
        
    }
    
    @IBAction func LoginButtonPressed(_ sender: Any) {
        if(EmailFiled.text != nil && PasswordField.text != nil){
            self.showSpinner(onView: self.view)
            Auth.auth().signIn(withEmail: EmailFiled.text!, password: PasswordField.text!) { authResult, error in
                self.removeSpinner()
                guard let user = authResult?.user, error == nil else {
                    self.LoginError()
                    return
                }
                self.uid = user.uid
                self.email = self.EmailFiled.text!
                self.ToFlightList()
            }
        }
        else{
            LoginError()
        }
    }
    
    @IBAction func SignupButtonPressed(_ sender: Any) {
            if(EmailFiled.text != nil && PasswordField.text != nil){
                Auth.auth().createUser(withEmail: EmailFiled.text!, password: PasswordField.text!) { authResult, error in
                     guard let user = authResult?.user, error == nil else {
                            self.LoginError()
                            return
                         }
                    self.uid = user.uid
                    self.email = self.EmailFiled.text!
                    self.ToFlightList()
            }
        }
            else{
                LoginError()
        }
        
    }
    func LoginError(){
        let ac = UIAlertController(title: "Error", message: "Could not log in or sign up", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    func ToFlightList(){
        if let vc = storyboard?.instantiateViewController(withIdentifier: "FlightList") as? ViewController{
            vc.uid = self.uid
            vc.email = self.email
            vc.container = container
            navigationController?.pushViewController(vc, animated: true)
        }
    }
        
    @IBAction func Test(_ sender: Any) {
        let testRecord = CKRecord(recordType: "Flights")
        testRecord["iataNumber"] = "ABCD" as CKRecordValue
        testRecord["departureDate"] = Date() as CKRecordValue
        let seat1Record = CKRecord(recordType: "Seat")
        seat1Record["number"] = "05FF"
        seat1Record["occupiedBy"] = "AAA"
        let seat2Record = CKRecord(recordType: "Seat")
        seat2Record["number"] = "18CC"
        seat2Record["occupiedBy"] = "BBB"
        let reference = CKRecord.Reference(recordID: testRecord.recordID, action: .none)
        
        seat1Record["flight"] = reference
        seat2Record["flight"] = reference
        
        let records = [testRecord, seat1Record, seat2Record]
        
        self.showSpinner(onView: self.view)
        saveRecords(records: records)
        self.removeSpinner()
        
    }
    
    func saveRecords(records : [CKRecord]){
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        operation.savePolicy = .ifServerRecordUnchanged
        CKContainer.default().publicCloudDatabase.add(operation)
        print("success")
        
    }
    
    @IBAction func iCloudRead(_ sender: Any) {
        let pred = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "iataNumber", ascending: true)
        let query = CKQuery(recordType: "Flights", predicate: pred)
        query.sortDescriptors = [sort]

        self.showSpinner(onView: self.view)
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil){ results, error in
            self.removeSpinner()
            if let error = error {
                print("Cloud Query Error - Fetch Establishments: \(error.localizedDescription)")
                return
            }
            for result in results!{
                print(result["departureDate"] ?? "Nil value")
                print(result["iataNumber"] ?? "Nil value")
                let flightID = result.recordID
                let recordToMatch = CKRecord.Reference(recordID: flightID, action: .none)
                let predicate = NSPredicate(format: "flight == %@", recordToMatch.recordID)
                let query2 = CKQuery(recordType: "Seat", predicate: predicate)
                CKContainer.default().publicCloudDatabase.perform(query2, inZoneWith: nil){results2, error in
                    if let error = error {
                        print("Cloud Query Error - Fetch Establishments: \(error.localizedDescription)")
                        return
                    }
                    for result2 in results2!{
                        print(result2["number"] ?? "Nil value")
                        print(result2["occupiedBy"] ?? "Nil value")
                    }
                }
            }
            
        }
    }
}

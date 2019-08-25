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
        setupContainer()
        
    }
    func setupContainer(){
        container = NSPersistentContainer(name: "FlightRider")
        
        container.loadPersistentStores { storeDescription, error in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
    }
    
    @IBAction func LoginButtonPressed(_ sender: Any) {
        if(EmailFiled.text != nil && PasswordField.text != nil){
            Auth.auth().signIn(withEmail: EmailFiled.text!, password: PasswordField.text!) { authResult, error in
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
            navigationController?.pushViewController(vc, animated: true)
        }
    }
        
    @IBAction func Test(_ sender: Any) {
        let testRecord = CKRecord(recordType: "Flights")
        testRecord["iataNumber"] = "FR110" as CKRecordValue
        testRecord["departureDate"] = Date() as CKRecordValue
        let seat1Record = CKRecord(recordType: "Seat")
        seat1Record["number"] = "05F"
        seat1Record["occupiedBy"] = "AA"
        let seat2Record = CKRecord(recordType: "Seat")
        seat2Record["number"] = "18C"
        seat2Record["occupiedBy"] = "BB"
        saveRecord(record: seat1Record)
        saveRecord(record: seat2Record)
        
        saveRecord(record: testRecord)
    }
    
    func saveRecord(record : CKRecord){
        CKContainer.default().publicCloudDatabase.save(record) { [unowned self] record, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else {
                    print("success")
                    
                    //self.isDirty = true
                }
            }
        }
    }
    
    @IBAction func iCloudRead(_ sender: Any) {
        let pred = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "number", ascending: true)
        let query = CKQuery(recordType: "Seat", predicate: pred)
        query.sortDescriptors = [sort]
        
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["number", "occupiedBy"]
        
        print(operation.recordFetchedBlock as Any)
    }
}

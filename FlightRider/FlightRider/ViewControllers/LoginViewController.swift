//
//  LoginViewController.swift
//  FlightRider
//
//  Created by Tomi on 2019. 08. 22..
//  Copyright © 2019. Tomi. All rights reserved.
//

import UIKit
import Firebase
import CloudKit
import CoreData

//var container: NSPersistentContainer!

class LoginViewController: UIViewController {

    @IBOutlet weak var rememberMeSwitch: UISwitch!
    @IBOutlet weak var PasswordField: UITextField!
    @IBOutlet weak var EmailFiled: UITextField!
    var uid : String = ""
    var email : String = ""
    var container: NSPersistentContainer!
    var spinnerView : UIView!
    var ai : UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        container = setupContainer()
        spinnerView = UIView.init(frame: self.view.bounds)
        ai = UIActivityIndicatorView.init(style: .whiteLarge)
        
        rememberMeSwitch.addTarget(self, action: #selector(self.stateChanged), for: .valueChanged)
        let defaults: UserDefaults? = UserDefaults.standard
        
        if (defaults?.bool(forKey: "ISRemember")) ?? false{
            EmailFiled.text = defaults?.value(forKey: "SavedUserName") as? String
            PasswordField.text = defaults?.value(forKey: "SavedPassword") as? String
            rememberMeSwitch.setOn(true, animated: false)
        }
        else {
            rememberMeSwitch.setOn(false, animated: false)
        }
    }
    
    @objc func stateChanged(_ switchState: UISwitch) {
        
        let defaults: UserDefaults? = UserDefaults.standard
        if switchState.isOn {
            defaults?.set(true, forKey: "ISRemember")
            defaults?.set(EmailFiled.text, forKey: "SavedUserName")
            defaults?.set(PasswordField.text, forKey: "SavedPassword")
        }
        else {
            defaults?.set(false, forKey: "ISRemember")
        }
    }
    
    @IBAction func LoginButtonPressed(_ sender: Any) {
        if(EmailFiled.text != nil && PasswordField.text != nil){
            if rememberMeSwitch.isOn {
                let defaults: UserDefaults? = UserDefaults.standard
                let savedName = defaults?.string(forKey: "SavedUserName")
                let savedPass = defaults?.string(forKey: "SavedPassword")
                
                if (savedName != EmailFiled.text){
                    defaults?.set(EmailFiled.text, forKey: "SavedUserName")
                }
                if (savedPass != PasswordField.text){
                    defaults?.set(PasswordField.text, forKey: "SavedPassword")
                }
            }
            showSpinner(view: self.view, spinnerView: spinnerView, ai: ai)
            Auth.auth().signIn(withEmail: EmailFiled.text!, password: PasswordField.text!) { authResult, error in
                guard let user = authResult?.user, error == nil else {
                    self.LoginError()
                    return
                }
                self.uid = user.uid
                self.email = self.EmailFiled.text!
                /*DispatchQueue.main.async {
                    self.ai?.stopAnimating()
                    self.spinnerView!.removeFromSuperview()
                }*/
                self.removeSpinner(spinnerView: self.spinnerView, ai: self.ai)
                self.ToFlightList()
            }
        }
        else{
            LoginError()
        }
    }
    
    @IBAction func SignupButtonPressed(_ sender: Any) {
            if(EmailFiled.text != nil && PasswordField.text != nil){
                showSpinner(view: self.view, spinnerView: spinnerView, ai: ai)
                Auth.auth().createUser(withEmail: EmailFiled.text!, password: PasswordField.text!) { authResult, error in
                     guard let user = authResult?.user, error == nil else {
                            self.LoginError()
                            return
                         }
                    self.uid = user.uid
                    self.email = self.EmailFiled.text!
                    self.removeSpinner(spinnerView: self.spinnerView, ai: self.ai)
                    self.ToFlightList()
            }
        }
            else{
                LoginError()
        }
        
    }
    func LoginError(){
        self.removeSpinner(spinnerView: self.spinnerView, ai: self.ai)
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
    
    func saveRecords(records : [CKRecord]){
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        operation.savePolicy = .ifServerRecordUnchanged
        CKContainer.default().publicCloudDatabase.add(operation)
        print("success")
        
    }
    
    
}

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

class LoginViewController_old: UIViewController {

    @IBOutlet weak var rememberMeSwitch: UISwitch!//view
    @IBOutlet weak var PasswordField: UITextField!//view
    @IBOutlet weak var EmailFiled: UITextField!//view
    var uid : String = ""//model
    var email : String = ""//model
    var spinnerView : UIView!//view
    var ai : UIActivityIndicatorView!//view
    let backgroundImageView = UIImageView()//view
    let databaseWorker = DatabaseWorker()//view
    
    //view+interactor+worker
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        self.databaseWorker.setupContainer()
        spinnerView = UIView.init(frame: self.view.bounds)
        ai = UIActivityIndicatorView.init(style: .whiteLarge)
        
        rememberMeSwitch.addTarget(self, action: #selector(self.stateChanged), for: .valueChanged)
        let defaults: UserDefaults? = UserDefaults.standard
        
        if (defaults?.bool(forKey: "ISRemember")) ?? false{
            EmailFiled.text = defaults?.value(forKey: "SavedUserName") as? String
            if let retrievedString = KeychainWrapper.standard.string(forKey: "SavedPassword"){
                PasswordField.text = retrievedString
            }
            rememberMeSwitch.setOn(true, animated: false)
        }
        else {
            rememberMeSwitch.setOn(false, animated: false)
        }
        setBackground()
    }
    
    //view + interactor + worker
    @objc func stateChanged(_ switchState: UISwitch) {
        
        let defaults: UserDefaults? = UserDefaults.standard
        if switchState.isOn {
            if EmailFiled.text != nil && PasswordField.text != nil{
                defaults?.set(true, forKey: "ISRemember")
                defaults?.set(EmailFiled.text!, forKey: "SavedUserName")
                let saveResult = KeychainWrapper.standard.set(PasswordField.text!, forKey: "SavedPassword")
                if !saveResult{
                    print("Password save to keychain was unsuccessful")
                }
            }

        }
        else {
            defaults?.set(false, forKey: "ISRemember")
        }
    }
    
    //view + interactor
    @IBAction func LoginButtonPressed(_ sender: Any) {
        if(EmailFiled.text != nil && PasswordField.text != nil){
            if rememberMeSwitch.isOn {
                let defaults: UserDefaults? = UserDefaults.standard
                let savedName = defaults?.string(forKey: "SavedUserName")
                //let savedPass = defaults?.string(forKey: "SavedPassword")
                let savedPass = KeychainWrapper.standard.string(forKey: "SavedPassword")
                
                if (savedName != EmailFiled.text){
                    defaults?.set(EmailFiled.text, forKey: "SavedUserName")
                }
                if (savedPass != PasswordField.text){
                    let saveResult = KeychainWrapper.standard.set(PasswordField.text!, forKey: "SavedPassword")
                    if !saveResult{
                        print("Password save to keychain was unsuccessful")
                    }
                }
            }
            showSpinner(view: self.view, spinnerView: spinnerView, ai: ai)
            Auth.auth().signIn(withEmail: EmailFiled.text!, password: PasswordField.text!) { [unowned self] authResult, error in
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
    
    //view+interactor
    @IBAction func SignupButtonPressed(_ sender: Any) {
            if(EmailFiled.text != nil && PasswordField.text != nil){
                showSpinner(view: self.view, spinnerView: spinnerView, ai: ai)
                Auth.auth().createUser(withEmail: EmailFiled.text!, password: PasswordField.text!) { [unowned self] authResult, error in
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
    
    //view
    func LoginError(){
        self.removeSpinner(spinnerView: self.spinnerView, ai: self.ai)
        let ac = UIAlertController(title: "Error", message: "Could not log in or sign up", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    //router
    func ToFlightList(){
        if let vc = storyboard?.instantiateViewController(withIdentifier: "FlightList") as? ViewController{
            vc.uid = self.uid
            vc.email = self.email
            //vc.container = container
            vc.databaseWorker = self.databaseWorker
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //worker
    func saveRecords(records : [CKRecord]){
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        operation.savePolicy = .ifServerRecordUnchanged
        CKContainer.default().publicCloudDatabase.add(operation)
        print("success")
        
    }
    
    //view
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //view
    func setBackground() {
        view.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        backgroundImageView.contentMode = .scaleAspectFill
        
        backgroundImageView.image = UIImage(named: "flight1")
        view.sendSubviewToBack(backgroundImageView)

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
    
}

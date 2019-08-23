//
//  LoginViewController.swift
//  FlightRider
//
//  Created by Tomi on 2019. 08. 22..
//  Copyright © 2019. Tomi. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var PasswordField: UITextField!
    @IBOutlet weak var EmailFiled: UITextField!
    var uid : String = ""
    var email : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
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
}

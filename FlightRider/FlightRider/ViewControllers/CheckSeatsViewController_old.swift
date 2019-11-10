//
//  CheckSeatsViewController.swift
//  FlightRider
//
//  Created by Tomi on 2019. 08. 05..
//  Copyright © 2019. Tomi. All rights reserved.
//

/*import UIKit

class CheckSeatsViewController_old: UIViewController {

    @IBOutlet weak var contentView: UIView!
    
    var flight : ManagedFlight!
    var user : ManagedUser!
    var justSelectedSeat : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(customBack))
        self.navigationItem.leftBarButtonItem = newBackButton
        createSeats()
        // Do any additional setup after loading the view.
    }
    
    @objc func customBack(){
        if(justSelectedSeat == true){
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        }
        else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func createSeats() {

        let viewSize = self.view.frame.width*0.0966
        let viewSpacing = self.view.frame.width*0.0169
        let lettersSpacing = self.view.frame.width*0.0724
        let fontSize = self.view.frame.width*0.0724
        let distanceFromTop = self.view.frame.height*0.0258
        let distanceFromLeading = self.view.frame.width*0.169
        let distanceFromTrailing = self.view.frame.width*0.1207
        let seatNumbersViewSpacing = self.view.frame.height*0.051
        let seatnumbersViewWidth = self.view.frame.width*0.0845
        let seatnumbersViewLeading = self.view.frame.width*0.0483
        let seatnumbersViewTop = self.view.frame.height*0.115
        let seatnumbersViewBottom = self.view.frame.height*0.06
        let cornerRadius = viewSize*0.25
        
        let leftLetters = UIStackView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        leftLetters.axis = .horizontal
        leftLetters.distribution = .fill
        leftLetters.alignment = .fill
        leftLetters.spacing = lettersSpacing
        leftLetters.translatesAutoresizingMaskIntoConstraints = false
        
        let rightLetters = UIStackView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        rightLetters.axis = .horizontal
        rightLetters.distribution = .fill
        rightLetters.alignment = .fill
        rightLetters.spacing = lettersSpacing
        rightLetters.translatesAutoresizingMaskIntoConstraints = false
        
        let path = Bundle.main.path(forResource: "AirplaneModels", ofType: "json")!
        let data = try? String(contentsOf: URL(fileURLWithPath: path))
        let jsonData = JSON(parseJSON: data!)
        let jsonArray = jsonData.arrayValue
        
        let jsonValue = jsonArray.filter{$0["modelName"].stringValue == self.flight.airplaneType}.first!
        let actualType = AirplaneModel(modelName: jsonValue["modelName"].stringValue, numberOfSeats: jsonValue["numberOfSeats"].intValue, latestColumn: jsonValue["columns"].stringValue)
        
       for i in 0...Array(actualType.columns).count - 1{
            let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            lbl.text = String(Array(actualType.columns)[i])
            lbl.font = UIFont(name: "Helvetica", size: fontSize)
            if(i <= 2){
                leftLetters.addArrangedSubview(lbl)
            }
            else{
                rightLetters.addArrangedSubview(lbl)
            }

        }
        
        contentView.addSubview(leftLetters)
        contentView.addSubview(rightLetters)
        
        NSLayoutConstraint(item: leftLetters, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: distanceFromTop).isActive = true
        NSLayoutConstraint(item: leftLetters, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: distanceFromLeading).isActive = true
        
        NSLayoutConstraint(item: rightLetters, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: distanceFromTop).isActive = true
        NSLayoutConstraint(item: rightLetters, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1.0, constant: -distanceFromTrailing).isActive = true

        let seatNumbersView = UIStackView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        seatNumbersView.axis = .vertical
        seatNumbersView.distribution = .fill
        seatNumbersView.alignment = .center
        seatNumbersView.spacing = seatNumbersViewSpacing
        seatNumbersView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(seatNumbersView)
        
        NSLayoutConstraint(item: seatNumbersView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: seatnumbersViewWidth).isActive = true
        NSLayoutConstraint(item: seatNumbersView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: seatnumbersViewLeading).isActive = true
        NSLayoutConstraint(item: seatNumbersView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: seatnumbersViewTop).isActive = true
        NSLayoutConstraint(item: seatNumbersView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -seatnumbersViewBottom).isActive = true

        
        
        for number in 1...actualType.numberOfSeats{
            let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            lbl.text = String(number)
            lbl.font = UIFont(name: "Helvetica", size: fontSize)
            seatNumbersView.addArrangedSubview(lbl)
            
            let stackViewABC = UIStackView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            stackViewABC.axis = .horizontal
            stackViewABC.distribution = .fill
            stackViewABC.alignment = .fill
            stackViewABC.spacing = viewSpacing
            stackViewABC.translatesAutoresizingMaskIntoConstraints = false
            
            
            let stackViewDEF = UIStackView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            stackViewDEF.axis = .horizontal
            stackViewDEF.distribution = .fill
            stackViewDEF.alignment = .fill
            stackViewDEF.spacing = viewSpacing
            stackViewDEF.translatesAutoresizingMaskIntoConstraints = false
            
            for i in 0...Array(actualType.columns).count - 1{
                let seatview = UIView(frame: CGRect(x: 0, y: 0, width: viewSize, height: viewSize))
                let result = flight.seats.filter{ $0.number == "\(String(format: "%02d", number))\(Array(actualType.columns)[i])" }
                if result.isEmpty{
                    seatview.backgroundColor = .blue
                }
                else if(result.first!.occupiedBy == user.email){
                    seatview.backgroundColor = .green
                }
                else{
                    seatview.backgroundColor = .red
                    Tap.on(view: seatview){
                        self.viewTapped(view: seatview, email: result.first!.occupiedBy)
                    }
                }
                
                seatview.layer.cornerRadius = cornerRadius
                seatview.translatesAutoresizingMaskIntoConstraints = false
                seatview.accessibilityIdentifier = "\(number)\(Array(actualType.columns)[i])"
                if(i <= 2){
                    stackViewABC.addArrangedSubview(seatview)
                }
                else{
                    stackViewDEF.addArrangedSubview(seatview)
                }

                NSLayoutConstraint(item: seatview, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: viewSize).isActive = true
                NSLayoutConstraint(item: seatview, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: viewSize).isActive = true
            }
            contentView.addSubview(stackViewABC)
            NSLayoutConstraint(item: stackViewABC, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: viewSize).isActive = true
            NSLayoutConstraint(item: stackViewABC, attribute: .centerX, relatedBy: .equal, toItem: leftLetters, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: stackViewABC, attribute: .centerY, relatedBy: .equal, toItem: lbl, attribute: .centerY, multiplier: 1.0, constant: 0.0).isActive = true
        
            
            contentView.addSubview(stackViewDEF)
            NSLayoutConstraint(item: stackViewDEF, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: viewSize).isActive = true
            NSLayoutConstraint(item: stackViewDEF, attribute: .centerX, relatedBy: .equal, toItem: rightLetters, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: stackViewDEF, attribute: .centerY, relatedBy: .equal, toItem: lbl, attribute: .centerY, multiplier: 1.0, constant: 0.0).isActive = true
        }
    }
    
    
    func viewTapped(view : UIView, email: String){
        let ac = UIAlertController(title: "This seat is reserved by \(email)", message: nil, preferredStyle: .alert)
        ac.message = "Feel free to start a conversation with this user"
        
        let contactAction = UIAlertAction(title: "Contact", style: .default) { /*[unowned self, unowned ac]*/ action in
            print("Not implemented yet. This will open the chat")
        }
        let exchangeAggreementAction = UIAlertAction(title: "Exchange Agreement", style: .default) { /*[unowned self, unowned ac]*/ action in
            print("Not implemented yet. This will open the Exchange Agreement tab")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        
        ac.addAction(contactAction)
        ac.addAction(exchangeAggreementAction)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }

}*/

//
//  CheckSeatsViewController.swift
//  FlightRider
//
//  Created by Tomi on 2019. 08. 05..
//  Copyright © 2019. Tomi. All rights reserved.
//

import UIKit

class CheckSeatsViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSeats()

        // Do any additional setup after loading the view.
    }
    
    func createSeats() {
        
        print(contentView.frame.width)
        print(contentView.frame.height)
        
        print(view.frame.width)
        print(view.frame.height)
        
        
        let viewSize = contentView.frame.width*0.0966
        let viewSpacing = contentView.frame.width*0.0169
        let lettersSpacing = contentView.frame.width*0.0724
        let fontSize = contentView.frame.width*0.0724
        let distanceFromTop = contentView.frame.height*0.0258
        let distanceFromLeading = contentView.frame.width*0.169
        let distanceFromTrailing = contentView.frame.width*0.1207
        let seatNumbersViewSpacing = contentView.frame.height*0.051
        let seatnumbersViewWidth = contentView.frame.width*0.0845
        let seatnumbersViewLeading = contentView.frame.width*0.0483
        let seatnumbersViewTop = contentView.frame.height*0.115
        let seatnumbersViewBottom = contentView.frame.height*0.06
        let cornerRadius = viewSize*0.25
        
        let leftLetters = UIStackView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        leftLetters.axis = .horizontal
        leftLetters.distribution = .fill
        leftLetters.alignment = .fill
        leftLetters.spacing = lettersSpacing
        leftLetters.translatesAutoresizingMaskIntoConstraints = false
        
        
        let lblA = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        lblA.text = "A"
        lblA.font = UIFont(name: "Helvetica", size: fontSize)
        leftLetters.addArrangedSubview(lblA)
        
        let lblB  = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        lblB.text = "B"
        lblB.font = UIFont(name: "Helvetica", size: fontSize)
        leftLetters.addArrangedSubview(lblB)
        
        let lblC = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        lblC.text = "C"
        lblC.font = UIFont(name: "Helvetica", size: fontSize)
        leftLetters.addArrangedSubview(lblC)
        
        let rightLetters = UIStackView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        rightLetters.axis = .horizontal
        rightLetters.distribution = .fill
        rightLetters.alignment = .fill
        rightLetters.spacing = lettersSpacing
        rightLetters.translatesAutoresizingMaskIntoConstraints = false
        
        let lblD = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        lblD.text = "D"
        lblD.font = UIFont(name: "Helvetica", size: fontSize)
        rightLetters.addArrangedSubview(lblD)
        
        let lblE  = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        lblE.text = "E"
        lblE.font = UIFont(name: "Helvetica", size: fontSize)
        rightLetters.addArrangedSubview(lblE)
        
        let lblF = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        lblF.text = "F"
        lblF.font = UIFont(name: "Helvetica", size: fontSize)
        rightLetters.addArrangedSubview(lblF)
        
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

        
        
        for i in 1...32{
            let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            lbl.text = String(i)
            lbl.font = UIFont(name: "Helvetica", size: fontSize)
            seatNumbersView.addArrangedSubview(lbl)
            
            let stackViewABC = UIStackView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            stackViewABC.axis = .horizontal
            stackViewABC.distribution = .fill
            stackViewABC.alignment = .fill
            stackViewABC.spacing = viewSpacing
            stackViewABC.translatesAutoresizingMaskIntoConstraints = false
            
            for _ in 0...2{
                let seatview = UIView(frame: CGRect(x: 0, y: 0, width: viewSize, height: viewSize))
                seatview.backgroundColor = .blue
                seatview.layer.cornerRadius = cornerRadius
                seatview.translatesAutoresizingMaskIntoConstraints = false
                stackViewABC.addArrangedSubview(seatview)
                NSLayoutConstraint(item: seatview, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: viewSize).isActive = true
                NSLayoutConstraint(item: seatview, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: viewSize).isActive = true
                Tap.on(view: seatview){
                    self.viewTapped(view: seatview)
                }
            }
            contentView.addSubview(stackViewABC)
            
            NSLayoutConstraint(item: stackViewABC, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: viewSize).isActive = true
            NSLayoutConstraint(item: stackViewABC, attribute: .centerX, relatedBy: .equal, toItem: leftLetters, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: stackViewABC, attribute: .centerY, relatedBy: .equal, toItem: lbl, attribute: .centerY, multiplier: 1.0, constant: 0.0).isActive = true
            
            let stackViewDEF = UIStackView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            stackViewDEF.axis = .horizontal
            stackViewDEF.distribution = .fill
            stackViewDEF.alignment = .fill
            stackViewDEF.spacing = viewSpacing
            stackViewDEF.translatesAutoresizingMaskIntoConstraints = false
            
            for _ in 0...2{
                let seatview = UIView(frame: CGRect(x: 0, y: 0, width: viewSize, height: viewSize))
                seatview.backgroundColor = .blue
                seatview.layer.cornerRadius = cornerRadius
                seatview.translatesAutoresizingMaskIntoConstraints = false
                stackViewDEF.addArrangedSubview(seatview)
                NSLayoutConstraint(item: seatview, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: viewSize).isActive = true
                NSLayoutConstraint(item: seatview, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: viewSize).isActive = true
                Tap.on(view: seatview){
                    self.viewTapped(view: seatview)
                }
            }
            contentView.addSubview(stackViewDEF)
            

            NSLayoutConstraint(item: stackViewDEF, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: viewSize).isActive = true
            NSLayoutConstraint(item: stackViewDEF, attribute: .centerX, relatedBy: .equal, toItem: rightLetters, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: stackViewDEF, attribute: .centerY, relatedBy: .equal, toItem: lbl, attribute: .centerY, multiplier: 1.0, constant: 0.0).isActive = true
        }
    }
    
    
    func viewTapped(view : UIView){
        print("Yay!")
        view.backgroundColor = .red
    }

}
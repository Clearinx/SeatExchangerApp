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
    @IBOutlet weak var seatNumbersView: UIStackView!
    @IBOutlet weak var ABC: UIStackView!
    @IBOutlet weak var DEF: UIStackView!
    @IBOutlet weak var test: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSeatNumbers()
        drawRectangle()
        //seatNumbersView.axis = NSLayoutConstraint.Axis.vertical

        // Do any additional setup after loading the view.
    }
    
    func createSeatNumbers() {
        
        for i in 2...32{
            let lbl = UILabel(frame: CGRect(x: 0, y: 50, width: 10, height: 10))
            lbl.text = String(i)
            lbl.font = UIFont(name: "Helvetica", size: 25)
            seatNumbersView.addArrangedSubview(lbl)
            
            let stackViewABC = UIStackView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            stackViewABC.axis = .horizontal
            stackViewABC.distribution = .fill
            stackViewABC.alignment = .fill
            stackViewABC.spacing = 7
            stackViewABC.translatesAutoresizingMaskIntoConstraints = false
            
            for _ in 0...2{
                let seatview = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                seatview.backgroundColor = .blue
                seatview.layer.cornerRadius = 10
                seatview.translatesAutoresizingMaskIntoConstraints = false
                stackViewABC.addArrangedSubview(seatview)
                NSLayoutConstraint(item: seatview, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40).isActive = true
                NSLayoutConstraint(item: seatview, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40).isActive = true
            }
            contentView.addSubview(stackViewABC)
            
            NSLayoutConstraint(item: stackViewABC, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40).isActive = true
            NSLayoutConstraint(item: stackViewABC, attribute: .centerX, relatedBy: .equal, toItem: ABC, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: stackViewABC, attribute: .centerY, relatedBy: .equal, toItem: lbl, attribute: .centerY, multiplier: 1.0, constant: 0.0).isActive = true
            
            let stackViewDEF = UIStackView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            stackViewDEF.axis = .horizontal
            stackViewDEF.distribution = .fill
            stackViewDEF.alignment = .fill
            stackViewDEF.spacing = 7
            stackViewDEF.translatesAutoresizingMaskIntoConstraints = false
            
            for _ in 0...2{
                let seatview = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                seatview.backgroundColor = .blue
                seatview.layer.cornerRadius = 10
                seatview.translatesAutoresizingMaskIntoConstraints = false
                stackViewDEF.addArrangedSubview(seatview)
                NSLayoutConstraint(item: seatview, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40).isActive = true
                NSLayoutConstraint(item: seatview, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40).isActive = true
            }
            contentView.addSubview(stackViewDEF)
            

            
            /*NSLayoutConstraint(item: stackViewABC, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 135).isActive = true*/
            NSLayoutConstraint(item: stackViewDEF, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40).isActive = true
            NSLayoutConstraint(item: stackViewDEF, attribute: .centerX, relatedBy: .equal, toItem: DEF, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: stackViewDEF, attribute: .centerY, relatedBy: .equal, toItem: lbl, attribute: .centerY, multiplier: 1.0, constant: 0.0).isActive = true
        }
        print(contentView.frame.size)
    }
    
    func drawRectangle() {
     
        /*let redView = UIView()
        redView.backgroundColor = .red
        redView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        redView.layer.cornerRadius = 10.0
        redView.translatesAutoresizingMaskIntoConstraints = false
        Tap.on(view: redView){
            self.viewTapped(view: redView)
        }
        
        let blackView = UIView()
        blackView.backgroundColor = .black
        blackView.frame = CGRect(x: 200, y: 850, width: 40, height: 40)
        blackView.layer.cornerRadius = 10.0
        blackView.translatesAutoresizingMaskIntoConstraints = false
        Tap.on(view: blackView){
            self.viewTapped(view: blackView)
        }
        
        //view.addSubview(redView)
        contentView.addSubview(blackView)
        /*NSLayoutConstraint(item: redView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40).isActive = true
        NSLayoutConstraint(item: redView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40).isActive = true
        NSLayoutConstraint(item: redView, attribute: .leadingMargin, relatedBy: .equal, toItem: view, attribute: .leadingMargin, multiplier: 1.0, constant: 64.0).isActive = true
        NSLayoutConstraint(item: redView, attribute: .topMargin, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1.0, constant: 100.0).isActive = true*/
        */
    }
    
    func viewTapped(view : UIView){
        print("Yay!")
        view.backgroundColor = .blue
    }
    
    
    /*override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let point = touch!.location(in: self.view)
        /*if layer.path!.contains(point) {
            print ("We tapped the square")
        }
        for view in view.subviews {
            let windowRect = self.view.convert(view.frame, from: self.view)
            if windowRect.contains(point) {
                print("Circled view")
            }
        }*/
    }*/
    
    
    
    
    

}

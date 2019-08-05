//
//  CheckSeatsViewController.swift
//  FlightRider
//
//  Created by Tomi on 2019. 08. 05..
//  Copyright © 2019. Tomi. All rights reserved.
//

import UIKit

class CheckSeatsViewController: UIViewController {

    @IBOutlet weak var testView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawRectangle()


        // Do any additional setup after loading the view.
    }
    
    func drawRectangle() {
        /*let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 40, height: 40), cornerRadius: 5).cgPath
        layer.fillColor = UIColor.red.cgColor
        let subview = UIView()
        subview.layer.addSublayer(layer)
        subview.translatesAutoresizingMaskIntoConstraints = false
        //subview.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        Tap.on(view: subview, fires: viewTapped)
        view.addSubview(subview)
        /*layer.path = UIBezierPath(roundedRect: CGRect(x: 64, y: 100, width: 40, height: 40), cornerRadius: 5).cgPath
        layer.fillColor = UIColor.red.cgColor
        let subview = UIView()
        subview.layer.addSublayer(layer)
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.screenTapped(_:)))
        subview.addGestureRecognizer(gesture)
        view.addSubview(subview)*/
        //subview.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        
        NSLayoutConstraint(item: subview, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leadingMargin, multiplier: 1.0, constant: 64.0).isActive = true
        NSLayoutConstraint(item: subview, attribute: .top, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1.0, constant: 100.0).isActive = true
        
        //view.layer.addSubview(subview)*/
        
        
        
        
        
        let redView = UIView()
        redView.backgroundColor = .red
        redView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        redView.layer.cornerRadius = 10.0
        redView.translatesAutoresizingMaskIntoConstraints = false
        Tap.on(view: redView, fires: viewTapped)
        view.addSubview(redView)
        
        NSLayoutConstraint(item: redView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40).isActive = true
        NSLayoutConstraint(item: redView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40).isActive = true
        NSLayoutConstraint(item: redView, attribute: .leadingMargin, relatedBy: .equal, toItem: view, attribute: .leadingMargin, multiplier: 1.0, constant: 64.0).isActive = true
        NSLayoutConstraint(item: redView, attribute: .topMargin, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1.0, constant: 100.0).isActive = true
        Tap.on(view: testView, fires: viewTapped)
        
    }
    
    func viewTapped(){
        print("Yay!")
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

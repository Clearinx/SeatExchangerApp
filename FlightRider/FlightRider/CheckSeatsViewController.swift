//
//  CheckSeatsViewController.swift
//  FlightRider
//
//  Created by Tomi on 2019. 08. 05..
//  Copyright © 2019. Tomi. All rights reserved.
//

import UIKit

class CheckSeatsViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawRectangle()


        // Do any additional setup after loading the view.
    }
    
    func drawRectangle() {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 40, height: 40), cornerRadius: 5).cgPath
        layer.fillColor = UIColor.red.cgColor
        let subview = UIView()
        subview.layer.addSublayer(layer)
        view.addSubview(subview)
        /*layer.path = UIBezierPath(roundedRect: CGRect(x: 64, y: 100, width: 40, height: 40), cornerRadius: 5).cgPath
        layer.fillColor = UIColor.red.cgColor
        let subview = UIView()
        subview.layer.addSublayer(layer)
        subview.translatesAutoresizingMaskIntoConstraints = false
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.screenTapped(_:)))
        subview.addGestureRecognizer(gesture)
        view.addSubview(subview)*/
        //subview.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        
        NSLayoutConstraint(item: subview, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leadingMargin, multiplier: 1.0, constant: 64.0).isActive = true
        NSLayoutConstraint(item: subview, attribute: .top, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1.0, constant: 100.0).isActive = true
        
        //view.layer.addSubview(subview)
    }
    
    
    /*override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let point = touch!.location(in: self.view)
        /*if layer.path!.contains(point) {
            print ("We tapped the square")
        }*/
        for view in view.subviews {
            let windowRect = self.view.window?.convert(view.frame, from: view.superview)
            if windowRect!.contains(point) {
                print("Circled view")
            }
        }
    }*/
    
    
    

}

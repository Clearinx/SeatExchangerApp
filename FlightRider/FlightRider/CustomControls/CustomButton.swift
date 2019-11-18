//
//  ViewController.swift
//  FlightRider
//
//  Created by Tomi on 2019. 09. 19..
//  Copyright © 2019. Tomi. All rights reserved.
//

import UIKit

class CustomButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

     func setupButton() {
        backgroundColor     = nil
        alpha               = 0.9
        //titleLabel?.font    = UIFont(name: "Arial", size: 30)
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [(#colorLiteral(red: 0.4068969488, green: 0.5874248147, blue: 0.8163669705, alpha: 1)).cgColor, (#colorLiteral(red: 0.8379636407, green: 0.8866117001, blue: 0.9216472507, alpha: 1)).cgColor]
        gradientLayer.cornerRadius = UIScreen.main.bounds.height * 0.025
        gradientLayer.masksToBounds = false
        layer.insertSublayer(gradientLayer, at: 0)

        layer.cornerRadius  = UIScreen.main.bounds.height * 0.025
        setTitleColor(.white, for: .normal)
    }
}

class SignUpButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }

    private func setupButton() {
        backgroundColor     = nil
        alpha               = 0.9
        layer.cornerRadius  = UIScreen.main.bounds.height * 0.025
        layer.borderColor = #colorLiteral(red: 0.4068969488, green: 0.5874248147, blue: 0.8163669705, alpha: 1)
        layer.borderWidth = 1.0
        layer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        setTitleColor(#colorLiteral(red: 0.4068969488, green: 0.5874248147, blue: 0.8163669705, alpha: 1), for: .normal)
    }
}

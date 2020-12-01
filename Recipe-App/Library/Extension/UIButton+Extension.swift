//
//  UIButton+Extension.swift
//  Recipe-App
//
//  Created by Selina on 01/12/2020.
//

import UIKit

extension UIButton{
    func makeRounded() {
        self.layer.borderWidth = 1
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = true
    }
}

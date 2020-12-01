//
//  UITableView+Extension.swift
//  Recipe-App
//
//  Created by Selina on 30/11/2020.
//

import UIKit

extension UITableView {
    
    func register<T: UITableViewCell>(_ aClass: T.Type, bundle bundleOrNil: Bundle? = nil) {
        let identifier = String(describing: aClass)
        if Bundle.main.path(forResource: identifier, ofType: "nib") != nil {
            register(UINib(nibName: identifier, bundle: bundleOrNil), forCellReuseIdentifier: identifier)
        } else {
            register(aClass, forCellReuseIdentifier: identifier)
        }
    }
    
    func dequeue<T: UITableViewCell>(_ aClass: T.Type, indexPath: IndexPath) -> T {
        let identifier = String(describing: aClass)
        guard let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
            fatalError("\(identifier) is not registered")
        }
        return cell
    }
}

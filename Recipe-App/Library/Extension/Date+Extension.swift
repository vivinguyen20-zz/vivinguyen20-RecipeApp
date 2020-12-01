//
//  Date+Extension.swift
//  Recipe-App
//
//  Created by Selina on 01/12/2020.
//

import Foundation

extension Date{
    static var currentTimeStamp: Int64{
        return  Int64(Date().timeIntervalSince1970 * 1000)
    }
}

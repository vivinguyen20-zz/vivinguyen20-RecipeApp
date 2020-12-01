//
//  RecipeType.swift
//  RecipeApp
//
//  Created by Selina on 30/11/2020.
//

import Foundation
import RealmSwift

class RecipeType: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
}


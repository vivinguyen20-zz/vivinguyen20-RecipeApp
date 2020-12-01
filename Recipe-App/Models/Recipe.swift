//
//  Recipe.swift
//  RecipeApp
//
//  Created by Selina on 30/11/2020.
//

import Foundation
import RealmSwift

class Recipe: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var ingredients = ""
    @objc dynamic var steps = ""
    @objc dynamic var imageUrl = ""
    @objc dynamic var type = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

struct Ingredient {
    var name: String
    var amount: String
    var unit: String
}


//
//  RecipeTableViewCellViewModel.swift
//  RecipeApp
//
//  Created by Selina on 30/11/2020.
//

import Foundation

final class RecipeTableViewCellViewModel {
    var recipe: Recipe
    var imageUrl: String {
        return recipe.imageUrl
    }
    var nameRecipe: String {
        return recipe.name
    }
    
    init(recipe: Recipe) {
        self.recipe = recipe
        
    }
}

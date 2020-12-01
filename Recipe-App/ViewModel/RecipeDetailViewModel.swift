//
//  RecipeDetailViewModel.swift
//  Recipe-App
//
//  Created by Selina on 30/11/2020.
//

import Foundation

protocol RecipeDetailViewModelDelegate: class {
    func viewModel(_ viewModel: RecipeDetailViewModel, needsPerform action: RecipeDetailViewModel.Action)
}

final class RecipeDetailViewModel {
    
    enum Action {
        case reloadData
    }
    
    var repcie: Recipe?
    private var recipes = [Recipe]()
    private let recipeClient = RecipeClient()
    private var recipesTypes: [RecipeType]!
    weak var delegate: RecipeDetailViewModelDelegate?
    
    init(repcie: Recipe = Recipe()) {
        self.repcie = repcie
        recipeClient.loadRecipeTypes()
        recipesTypes = recipeClient.fetchRecipeType()
    }
    func numberOfComponents() -> Int {
        return recipesTypes.count
    }
    
    func recipeTypeList() ->[RecipeType] {
        return recipesTypes
    }
    
    
    func saveRecipe(recipe: Recipe, name: String, type: String, ingredients: String, steps: String, imageUrl: String) -> Void {
        try? recipeClient.realmManager.update {
            recipe.name = name
            recipe.type = type
            recipe.ingredients = ingredients
            recipe.steps = steps
            recipe.imageUrl = imageUrl
        }
    }
    
    func deleteRecipe(_ recipe: Recipe) -> Void {
        recipeClient.realmManager.delete(object: recipe)
    }
}

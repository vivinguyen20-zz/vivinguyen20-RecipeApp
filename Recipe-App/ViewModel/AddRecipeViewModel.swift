//
//  AddRecipeViewModel.swift
//  Recipe-App
//
//  Created by Selina on 01/12/2020.
//

import Foundation

protocol AddRecipeViewModelDelegate: class {
    func viewModel(_ viewModel: AddRecipeViewModel , needsPerform action: AddRecipeViewModel .Action)
}

final class AddRecipeViewModel {
    
    enum Action {
        case reloadData
    }
    
    var repcie: Recipe?
    private var recipes = [Recipe]()
    private let recipeClient = RecipeClient()
    private var recipesTypes: [RecipeType]!
    weak var delegate: AddRecipeViewModelDelegate?
    
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
    
    func addRecipe( name: String, type: String, ingredients: String, steps: String, imageUrl: String) -> Void {
        let recipe = Recipe()
        recipe.name = name
        recipe.type = type
        recipe.ingredients = ingredients
        recipe.steps = steps
        recipe.imageUrl = imageUrl
        recipeClient.addRecipe(recipe)
    }
    
}

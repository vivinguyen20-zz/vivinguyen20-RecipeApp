//
//  HomeViewModel.swift
//  RecipeApp
//
//  Created by Selina on 30/11/2020.
//

import Foundation

final class HomeViewModel {
    private var recipes: [Recipe]!
    private var recipeClient = RecipeClient()
    private var recipesTypes: [RecipeType]{
        
        return recipeClient.recipeTypes
    }
    
    init() {
        recipeClient.loadRecipeTypes()
        recipeClient.loadRecipes()
        recipes = recipeClient.fetchRecipes()
    }
    
    func numberOfSections() -> Int {
        return recipes.count
    }
    
    func numberOfComponents() -> Int {
        return recipesTypes.count
    }
    
    
    func viewModelForItems(at indexPath: IndexPath) -> RecipeTableViewCellViewModel? {
        let recipe = recipes[indexPath.row]
        return RecipeTableViewCellViewModel(recipe: recipe)
    }
    
    func reloadRecipes() {
        recipes = recipeClient.fetchRecipes()
    }
    
    func filterRecipeByTypeID(_ typeName: String) {
        recipes = recipeClient.fetchRecipes(of: typeName)
    }
    
    func getDetailViewModel(atIndexPath indexPath: IndexPath) -> RecipeDetailViewModel {
        guard 0 <= indexPath.row && indexPath.row < recipes.count else { return RecipeDetailViewModel() }
        return RecipeDetailViewModel(repcie: recipes[indexPath.row])
    }
    
    func name(_ index: Int) -> String {
        if index == 0 {
            return "Show All"
        }
        else{
            return recipesTypes[index - 1].name
        }
    }
    
}

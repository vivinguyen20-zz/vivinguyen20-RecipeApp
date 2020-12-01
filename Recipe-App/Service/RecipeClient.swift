//
//  RecipeClient.swift
//  RecipeApp
//
//  Created by Selina on 30/11/2020.
//

import Foundation
import SWXMLHash

class RecipeClient {
    
    var recipeTypes = [RecipeType]()
    
    var realmManager = DatabaseManager.shared
    
    func loadRecipeTypes() {
        if let results = realmManager.fetch(RecipeType.self) {
            if results.isEmpty {
                loadRecipeTypesFromBundle()
            } else {
                recipeTypes = Array(results)
            }
        }
    }
    
    func loadRecipes() {
        if let results = realmManager.fetch(Recipe.self), results.isEmpty {
            loadRecipesFromBundle()
        }
    }
    
    func fetchRecipes(of type: String = "") -> [Recipe] {
        var recipes = [Recipe]()
        if type == "Show All" || type.isEmpty{
            if let results = realmManager.fetch(Recipe.self) {
                recipes = Array(results)
            }
        } else {
            if let results = realmManager.fetch(Recipe.self, predicate: NSPredicate(format: "type == %@", type)) {
                recipes = Array(results)
            }
        }
        return recipes
    }
    func fetchRecipeType() -> [RecipeType] {
        var recipeTypes = [RecipeType]()
        if let results = realmManager.fetch(RecipeType.self) {
            recipeTypes = Array(results)
        }
        return recipeTypes
    }
    
    func addRecipe(_ recipe: Recipe) {
        try? realmManager.create(Recipe.self, completion: { newRecipe in
            newRecipe.name        = recipe.name
            newRecipe.type        = recipe.type
            newRecipe.ingredients = recipe.ingredients
            newRecipe.steps       = recipe.steps
            newRecipe.imageUrl    = recipe.imageUrl
        })
    }
    
    
    private func loadRecipeTypesFromBundle() {
        guard let path = Bundle.main.path(forResource: "recipetypes", ofType: "xml") else { return }
        
        
        let xmlContent = try! String(contentsOfFile: path)
        let xml = SWXMLHash.parse(xmlContent)
        
        
        for elem in xml["recipetypes"]["recipetype"].all {
            try? realmManager.create(RecipeType.self) { [weak self] recipeType in
                guard let self = self else { return }
                recipeType.name = elem["name"].element!.text
                self.recipeTypes.append(recipeType)
            }
        }
    }
    
    private func loadRecipesFromBundle() {
        guard let path = Bundle.main.path(forResource: "recipes", ofType: "xml") else { return }
        
        
        let xmlContent = try! String(contentsOfFile: path)
        let xml = SWXMLHash.parse(xmlContent)
        
        for elem in xml["recipes"]["recipe"].all {
            var ingredients: [Ingredient] = []
            var steps: [String] = []
            
            let type = elem["type"].element!.text
            let name = elem["name"].element!.text
            let imageUrl = elem["image_url"].element!.text
            
            for i in elem["ingredient"].all {
                let ingredient = Ingredient(
                    name: i.element!.attribute(by: "name")?.text ?? "",
                    amount: i.element!.attribute(by: "amount")?.text ?? "",
                    unit: i.element!.attribute(by: "unit")?.text ?? "")
                ingredients.append(ingredient)
            }
            
            for i in elem["steps"]["step"].all {
                steps.append(i.element?.text ?? "-")
            }
            
            let ingredients__ =  ingredients.map{ e in e.amount + " " + e.unit + " " + e.name }
            let ingredientString = " - " + ingredients__.joined(separator: "\n - ")
            let stepsString = steps.map { e in e.trimmingCharacters(in: .whitespaces)}.joined(separator: "\n\n")
            
            try? realmManager.create(Recipe.self) { recipe in
                recipe.name = name
                recipe.type = type
                recipe.ingredients = ingredientString
                recipe.steps = stepsString
                recipe.imageUrl = imageUrl
            }
        }
    }
    
    
}

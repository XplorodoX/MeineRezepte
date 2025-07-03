//
//  Store.swift
//  MeineRezepte
//
//  Created by Florian Merlau on 03.07.25.
//

import SwiftUI
import Combine

// Manages the collection of recipes, persists to UserDefaults
class RecipeStore: ObservableObject {
    @Published var recipes: [Recipe] {
        didSet {
            // Encode and save recipes to UserDefaults whenever the recipes array changes.
            if let encoded = try? JSONEncoder().encode(recipes) {
                UserDefaults.standard.set(encoded, forKey: "recipes")
            }
        }
    }

    init() {
        // Attempt to load saved recipes from UserDefaults on initialization.
        if let savedRecipes = UserDefaults.standard.data(forKey: "recipes") {
            if let decodedRecipes = try? JSONDecoder().decode([Recipe].self, from: savedRecipes) {
                self.recipes = decodedRecipes
                return
            }
        }
        // If no saved recipes or decoding fails, initialize with an empty array.
        self.recipes = []
    }

    // Adds a new recipe to the store.
    func addRecipe(_ recipe: Recipe) {
        recipes.append(recipe)
    }

    // Updates an existing recipe in the store.
    func updateRecipe(_ updatedRecipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == updatedRecipe.id }) {
            recipes[index] = updatedRecipe
        }
    }

    // Deletes recipes at specified offsets (used with ForEach and onDelete).
    func deleteRecipe(at offsets: IndexSet) {
        recipes.remove(atOffsets: offsets)
    }

    // Retrieves a recipe by its ID.
    func getRecipe(by id: UUID) -> Recipe? {
        recipes.first(where: { $0.id == id })
    }
}

// Manages the meal plan entries, persists to UserDefaults
class MealPlannerStore: ObservableObject {
    @Published var mealPlan: [MealPlanEntry] {
        didSet {
            // Encode and save meal plan to UserDefaults whenever the mealPlan array changes.
            if let encoded = try? JSONEncoder().encode(mealPlan) {
                UserDefaults.standard.set(encoded, forKey: "mealPlan")
            }
        }
    }

    init() {
        // Attempt to load saved meal plan from UserDefaults on initialization.
        if let savedMealPlan = UserDefaults.standard.data(forKey: "mealPlan") {
            if let decodedMealPlan = try? JSONDecoder().decode([MealPlanEntry].self, from: savedMealPlan) {
                self.mealPlan = decodedMealPlan
                return
            }
        }
        // If no saved meal plan or decoding fails, initialize with an empty array.
        self.mealPlan = []
    }

    // Adds or updates a meal entry for a specific date.
    // If an entry for the date already exists, it's replaced.
    func addOrUpdateMeal(_ recipeID: UUID, for date: Date) {
        // Remove any existing entry for the given date to avoid duplicates.
        mealPlan.removeAll(where: { Calendar.current.isDate($0.date, inSameDayAs: date) })
        // Add the new meal plan entry.
        mealPlan.append(MealPlanEntry(date: date, recipeID: recipeID))
    }

    // Removes a meal entry for a specific date.
    func removeMeal(for date: Date) {
        mealPlan.removeAll(where: { Calendar.current.isDate($0.date, inSameDayAs: date) })
    }

    // Retrieves a meal entry for a specific date.
    func getMeal(for date: Date) -> MealPlanEntry? {
        mealPlan.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) })
    }

    // Auto-generates a meal plan for the current week using available recipes.
    func autoGenerateMealPlan(from recipes: [Recipe]) {
        guard !recipes.isEmpty else { return } // Cannot generate if no recipes exist.

        let today = Date()
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday

        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) ?? today

        // Clear existing meal plan for the current week before generating.
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                removeMeal(for: date)
            }
        }

        // Randomly assign recipes to each day of the week.
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                if let randomRecipe = recipes.randomElement() {
                    addOrUpdateMeal(randomRecipe.id, for: date)
                }
            }
        }
    }
}

//
//  ShoppingListView.swift
//  MeineRezepte
//
//  Created by Florian Merlau on 03.07.25.
//
import SwiftUI
import SwiftData

struct ShoppingListView: View {
    @EnvironmentObject var recipeStore: RecipeStore
    @EnvironmentObject var mealPlannerStore: MealPlannerStore
    @State private var shoppingListItems: [String] = []

    var body: some View {
        VStack {
            Text("Einkaufsliste")
                .font(.largeTitle)
                .padding(.bottom)

            Button("Einkaufsliste generieren (aktuelle Woche)") {
                generateShoppingList()
            }
            .padding(.bottom)

            List {
                ForEach(shoppingListItems, id: \.self) { item in
                    Text(item)
                }
            }
            Spacer()
        }
        .padding()
        .onAppear(perform: generateShoppingList) // Generate on appear

    }

    private func generateShoppingList() {
        var collectedIngredients: [String: Double] = [:] // Ingredient name: quantity
        var collectedUnits: [String: String] = [:] // Ingredient name: unit (e.g., "g", "ml", "Tassen")

        let today = Date()
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday

        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) ?? today

        // Collect ingredients from recipes planned for the current week
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek),
               let mealEntry = mealPlannerStore.getMeal(for: date),
               let recipe = recipeStore.getRecipe(by: mealEntry.recipeID) {

                // Simple parsing of ingredients
                let lines = recipe.ingredients.split(separator: "\n").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                for line in lines {
                    let components = line.split(separator: " ", maxSplits: 2) // e.g., "100 g Zucker" -> ["100", "g", "Zucker"]
                    if components.count >= 2, let quantity = Double(components[0].replacingOccurrences(of: ",", with: ".")) {
                        let unit = String(components[1])
                        let name = components.count > 2 ? String(components[2]) : ""

                        let fullIngredientName = "\(name) (\(unit))" // Combine name and unit for unique key
                        collectedIngredients[fullIngredientName, default: 0.0] += quantity
                        collectedUnits[fullIngredientName] = unit // Store the unit
                    } else {
                        // If not parsable, add as-is to a separate "misc" category or handle differently
                        collectedIngredients[line, default: 0.0] += 1.0 // Add as a single item
                        collectedUnits[line] = "" // No unit
                    }
                }
            }
        }

        // Format the collected ingredients into displayable strings
        var formattedList: [String] = []
        for (ingredient, quantity) in collectedIngredients.sorted(by: { $0.key < $1.key }) {
            if let unit = collectedUnits[ingredient], !unit.isEmpty {
                formattedList.append(String(format: "%.1f %@ %@", quantity, unit, ingredient.replacingOccoccurences(of: " (\(unit))", with: "")))
            } else {
                formattedList.append(ingredient) // For items without a clear quantity/unit
            }
        }
        shoppingListItems = formattedList
    }
}

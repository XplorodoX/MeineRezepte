//
//  AddEditRecipeView.swift
//  MeineRezepte
//
//  Created by Florian Merlau on 03.07.25.
//
import SwiftUI
import SwiftData

struct AddEditRecipeView: View {
    @Environment(\.dismiss) var dismiss // Environment value to dismiss the sheet.
    var recipe: Recipe? // Optional: if nil, it's a new recipe; otherwise, it's for editing.
    var onSave: (Recipe) -> Void // Closure to call when the recipe is saved.

    // @State variables to hold the input values for the form.
    @State private var title: String
    @State private var ingredients: String
    @State private var instructions: String
    @State private var servings: Double
    @State private var url: String

    // Custom initializer to set initial state based on whether a recipe is provided.
    init(recipe: Recipe?, onSave: @escaping (Recipe) -> Void) {
        self.recipe = recipe
        self.onSave = onSave
        // Initialize state variables with existing recipe data or empty/default values.
        _title = State(initialValue: recipe?.title ?? "")
        _ingredients = State(initialValue: recipe?.ingredients ?? "")
        _instructions = State(initialValue: recipe?.instructions ?? "")
        _servings = State(initialValue: recipe?.servings ?? 1.0)
        _url = State(initialValue: recipe?.url ?? "") // Initialize URL field
    }

    var body: some View {
        NavigationView { // Embed in NavigationView for toolbar buttons.
            Form { // Form provides structured input fields.
                TextField("Rezepttitel", text: $title) // Input for recipe title.
                TextField("Quell-URL (optional)", text: $url) // New: Input for recipe URL.
                    .keyboardType(.URL)
                Section("Zutaten") {
                    TextEditor(text: $ingredients) // Multi-line input for ingredients.
                        .frame(minHeight: 100)
                }
                Section("Zubereitung") {
                    TextEditor(text: $instructions) // Multi-line input for instructions.
                        .frame(minHeight: 150)
                }
                Stepper(value: $servings, in: 1...10, step: 0.5) {
                    Text("Portionen: \(servings, specifier: "%.1f")") // Stepper for servings.
                }
            }
            .padding()
            .navigationTitle(recipe == nil ? "Neues Rezept" : "Rezept bearbeiten") // Dynamic title.
            .toolbar {
                // Toolbar item to cancel and dismiss the sheet.
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                // Toolbar item to save the recipe.
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        // Create a new Recipe object with current input values.
                        let newRecipe = Recipe(
                            id: recipe?.id ?? UUID(), // Use existing ID if editing, new UUID if adding.
                            title: title,
                            ingredients: ingredients,
                            instructions: instructions,
                            servings: servings,
                            url: url.isEmpty ? nil : url // Save URL only if not empty
                        )
                        onSave(newRecipe) // Call the onSave closure.
                        dismiss() // Dismiss the sheet.
                    }
                    // Disable save button if any required fields are empty.
                    .disabled(title.isEmpty || ingredients.isEmpty || instructions.isEmpty)
                }
            }
        }
        .frame(minWidth: 400, minHeight: 500) // Set a reasonable minimum size for the sheet.
    }
}

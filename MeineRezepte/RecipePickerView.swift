//
//  RecipePickerView.swift
//  MeineRezepte
//
//  Created by Florian Merlau on 03.07.25.
//
import SwiftUI
import SwiftData

struct RecipePickerView: View {
    @EnvironmentObject var recipeStore: RecipeStore // Access the list of available recipes.
    @Environment(\.dismiss) var dismiss // Environment value to dismiss the sheet.
    @State private var internalSelectedRecipeID: UUID? // Local state for the selected recipe ID.
    var onSelect: (UUID?) -> Void // Closure to call when a recipe is selected (or cleared).

    // Custom initializer to set the initial selection.
    init(selectedRecipeID: UUID?, onSelect: @escaping (UUID?) -> Void) {
        _internalSelectedRecipeID = State(initialValue: selectedRecipeID)
        self.onSelect = onSelect
    }

    var body: some View {
        NavigationView { // Embed in NavigationView for title and toolbar.
            VStack {
                // List of recipes, allowing single selection.
                List(selection: $internalSelectedRecipeID) {
                    ForEach(recipeStore.recipes) { recipe in
                        Text(recipe.title)
                            .tag(recipe.id as UUID?) // Tag each row with its recipe ID.
                    }
                }
                Spacer() // Pushes buttons to the bottom.
                HStack {
                    // Button to cancel the selection.
                    Button("Abbrechen") {
                        dismiss()
                    }
                    Spacer()
                    // Button to confirm the selection.
                    Button("Auswählen") {
                        onSelect(internalSelectedRecipeID) // Call onSelect with the chosen ID.
                        dismiss()
                    }
                    .disabled(internalSelectedRecipeID == nil) // Disable if no recipe is selected.
                    // Button to clear the selection (remove meal for the day).
                    Button("Löschen") {
                        onSelect(nil) // Call onSelect with nil to clear.
                        dismiss()
                    }
                }
                .padding()
            }
            .navigationTitle("Rezept auswählen") // Title for the picker sheet.
        }
        .frame(minWidth: 300, minHeight: 400) // Set a reasonable minimum size for the sheet.
    }
}

//
//  RecipeListView.swift
//  MeineRezepte
//
//  Created by Florian Merlau on 03.07.25.
//
import SwiftUI
import SwiftData

// Displays a list of recipes, allowing addition and deletion.
struct RecipeListView: View {
    @EnvironmentObject var recipeStore: RecipeStore // Access the shared recipe data.
    @State private var showingAddRecipeSheet = false // Controls presentation of the add/edit sheet.

    var body: some View {
        VStack {
            List {
                // Iterate over recipes to display them.
                ForEach(recipeStore.recipes) { recipe in
                    // NavigationLink to show RecipeDetailView when a recipe is selected.
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)
                                    .environmentObject(recipeStore)) {
                        Text(recipe.title)
                            .font(.headline) // Make recipe titles stand out.
                    }
                }
                .onDelete(perform: recipeStore.deleteRecipe) // Enable swipe-to-delete or EditButton deletion.
            }
            .navigationTitle("Meine Rezepte") // Title for the recipe list view.
            .toolbar {
                // Toolbar item to add a new recipe.
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddRecipeSheet = true // Show the sheet to add a new recipe.
                    } label: {
                        Label("Neues Rezept", systemImage: "plus") // Plus icon for adding.
                    }
                }
                // Toolbar item for the Edit button, enabling deletion.
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            // Sheet for adding/editing a recipe.
            .sheet(isPresented: $showingAddRecipeSheet) {
                // Pass nil for a new recipe, and a closure to handle saving.
                AddEditRecipeView(recipe: nil) { newRecipe in
                    recipeStore.addRecipe(newRecipe) // Add the new recipe to the store.
                }
            }
        }
    }
}

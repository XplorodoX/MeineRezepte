//  RecipeDetailView.swift
//  MeineRezepte
//
//  Created by Florian Merlau on 03.07.25.
//
import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    @EnvironmentObject var recipeStore: RecipeStore // Access the shared recipe data.
    @State var recipe: Recipe // The recipe being displayed/edited. @State allows local modifications.
    @State private var showingEditRecipeSheet = false // Controls presentation of the edit sheet.
    @State private var showingStepByStepMode = false // Controls presentation of step-by-step mode.
    @State private var scaleFactor: Double = 1.0 // Factor for scaling ingredients.

    var body: some View {
        ScrollView { // Allows content to scroll if it exceeds view bounds.
            VStack(alignment: .leading, spacing: 15) {
                // NEU: Bild anzeigen, wenn vorhanden
                if let imageName = recipe.imageName, let uiImage = UIImage(named: imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10)
                        .padding(.bottom, 5)
                }
                
                Text(recipe.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)

                HStack {
                    Text("Portionen:")
                        .font(.headline)
                    // TextField for editing the number of servings.
                    TextField("", value: $recipe.servings, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 60)
                        .onChange(of: recipe.servings) { _ in
                            // Update the recipe in the store immediately when servings change.
                            recipeStore.updateRecipe(recipe)
                        }
                }

                // Display URL if available
                if let urlString = recipe.url, let url = URL(string: urlString) {
                    Link(destination: url) {
                        Text(urlString)
                            .font(.callout)
                            .foregroundColor(.blue)
                            .underline()
                    }
                    .padding(.bottom, 5)
                }

                Divider() // Visual separator.

                Text("Zutaten:")
                    .font(.title2)
                    .fontWeight(.semibold)

                // Display scaled ingredients using a helper function.
                Text(scaledIngredients(recipe.ingredients, originalServings: recipe.servings, scaleFactor: scaleFactor))
                    .font(.body)
                    .padding(.leading, 10)

                Divider()

                Text("Zubereitung:")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(recipe.instructions)
                    .font(.body)
                    .padding(.leading, 10)

                Spacer() // Pushes content to the top.
            }
            .padding() // Padding around the VStack content.
            .toolbar {
                // Toolbar item to edit the current recipe.
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingEditRecipeSheet = true // Show the sheet to edit the recipe.
                    } label: {
                        Label("Rezept bearbeiten", systemImage: "pencil") // Pencil icon for editing.
                    }
                }
                // New: Toolbar item for step-by-step mode.
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingStepByStepMode = true
                    } label: {
                        Label("Schritt-für-Schritt", systemImage: "play.fill")
                    }
                }
                // Toolbar item for the scaling slider at the bottom of the view.
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Text("Skalieren auf:")
                        Slider(value: $scaleFactor, in: 0.5...4.0, step: 0.5) {
                            Text("Skalierungsfaktor") // Accessibility label for the slider.
                        } minimumValueLabel: {
                            Text("0.5x")
                        } maximumValueLabel: {
                            Text("4x")
                        }
                        .frame(width: 200) // Constrain slider width.
                        Text(String(format: "%.1fx", scaleFactor)) // Display current scale factor.
                    }
                }
            }
            // Sheet for editing the recipe.
            .sheet(isPresented: $showingEditRecipeSheet) {
                // Pass the current recipe for editing, and a closure to handle saving.
                AddEditRecipeView(recipe: recipe) { updatedRecipe in
                    recipeStore.updateRecipe(updatedRecipe) // Update the recipe in the store.
                    self.recipe = updatedRecipe // Update the local @State recipe to reflect changes.
                }
            }
            // New: Sheet for step-by-step mode.
            .sheet(isPresented: $showingStepByStepMode) {
                StepByStepRecipeView(instructions: recipe.instructions)
            }
        }
    }

    // Function to scale ingredients based on a simple numerical prefix.
    // It assumes ingredients are formatted like "2 cups sugar" or "100g flour".
    func scaledIngredients(_ ingredients: String, originalServings: Double, scaleFactor: Double) -> String {
        guard originalServings > 0 else { return ingredients } // Prevent division by zero.

        let lines = ingredients.split(separator: "\n") // Split ingredients into individual lines.
        var scaledLines: [String] = []

        for line in lines {
            let components = line.split(separator: " ", maxSplits: 1) // Split by first space.
            // Check if there are two components and the first can be converted to a Double.
            if components.count == 2, let value = Double(components[0]) {
                let scaledValue = value * scaleFactor // Apply the scale factor.
                // Format the scaled value to one decimal place and append the rest of the line.
                scaledLines.append(String(format: "%.1f %@", scaledValue, String(components[1])))
            } else {
                // If not a parsable numerical ingredient, keep the line as is.
                scaledLines.append(String(line))
            }
        }
        return scaledLines.joined(separator: "\n") // Join scaled lines back with newlines.
    }
}

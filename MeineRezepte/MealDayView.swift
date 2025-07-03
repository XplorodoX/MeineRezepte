//
//  MealDayView.swift
//  MeineRezepte
//
//  Created by Florian Merlau on 03.07.25.
//
import SwiftUI
import SwiftData

struct MealDayView: View {
    @EnvironmentObject var recipeStore: RecipeStore // Access recipe data.
    @EnvironmentObject var mealPlannerStore: MealPlannerStore // Access meal plan data.
    let date: Date // The date this day view represents.
    @State private var showingRecipePicker = false // Controls presentation of the recipe picker sheet.

    var body: some View {
        VStack {
            Text(formattedDay(date)) // Display the day of the week and date.
                .font(.subheadline)
                .padding(.bottom, 5)

            // Check if there's a meal planned for this date.
            if let mealEntry = mealPlannerStore.getMeal(for: date),
               let recipe = recipeStore.getRecipe(by: mealEntry.recipeID) {
                // If a recipe is planned, display its title.
                Text(recipe.title)
                    .font(.caption)
                    .lineLimit(2) // Limit to two lines for long titles.
                    .multilineTextAlignment(.center)
                    .padding(5)
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor.opacity(0.2)) // Highlight planned meals.
                    .cornerRadius(5)
                    .onTapGesture {
                        showingRecipePicker = true // Tap to change the assigned recipe.
                    }
                // Button to remove the planned meal for this day.
                Button(action: {
                    mealPlannerStore.removeMeal(for: date)
                }) {
                    Image(systemName: "xmark.circle.fill") // Red 'X' icon.
                        .foregroundColor(.red)
                        .font(.caption)
                }
                .buttonStyle(BorderlessButtonStyle()) // Minimalist button style.
            } else {
                // If no recipe is planned, display an "Add Recipe" button.
                Button("Rezept hinzufügen") {
                    showingRecipePicker = true // Show the recipe picker.
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .padding(.vertical, 5)
            }
        }
        .frame(minHeight: 100) // Ensure consistent height for each day.
        .padding(5)
        .background(Color.gray.opacity(0.1)) // Light gray background.
        .cornerRadius(8)
        // Sheet for picking a recipe.
        .sheet(isPresented: $showingRecipePicker) {
            // Pass the currently selected recipe ID (if any) and a closure for selection.
            RecipePickerView(selectedRecipeID: mealPlannerStore.getMeal(for: date)?.recipeID) { selectedRecipeID in
                if let id = selectedRecipeID {
                    mealPlannerStore.addOrUpdateMeal(id, for: date) // Add or update the meal.
                } else {
                    mealPlannerStore.removeMeal(for: date) // Option to clear the meal for the day.
                }
                showingRecipePicker = false // Dismiss the picker sheet.
            }
            .environmentObject(recipeStore) // Inject recipeStore into the picker.
        }
    }

    // Helper function to format the day and date (e.g., "Mon\n1. Jan").
    func formattedDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE\nd. MM" // EEE for abbreviated weekday, d. MM for day and month.
        return formatter.string(from: date)
    }
}

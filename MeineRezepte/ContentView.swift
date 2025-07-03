//
//  ContentView.swift
//  MeineRezepte
//
//  Created by Florian Merlau on 03.07.25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // State objects for managing application data.
    @StateObject private var recipeStore = RecipeStore()
    @StateObject private var mealPlannerStore = MealPlannerStore()
    // State for controlling the currently selected tab in the sidebar.
    @State private var selectedTab: Tab = .recipes

    // AppStorage for custom accent color.
    @AppStorage("appAccentColor") private var appAccentColorData: Data = Data()

    // Computed property to get/set the Color from Data.
    var customAccentColor: Color {
        get {
            guard let decodedColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: appAccentColorData) else {
                return .blue // Default color if decoding fails
            }
            return Color(decodedColor)
        }
        set {
            if let encodedColor = try? NSKeyedArchiver.archivedData(withRootObject: NSColor(newValue), requiringSecureCoding: false) {
                appAccentColorData = encodedColor
            }
        }
    }

    // Enum to define the available tabs/sections of the app.
    enum Tab {
        case recipes
        case mealPlanner
        case shoppingList
        case converter
        case settings
    }

    var body: some View {
        NavigationSplitView {
            // Sidebar for navigation, listing the main sections of the app.
            List(selection: $selectedTab) {
                // NavigationLink for the Recipes section.
                NavigationLink(value: Tab.recipes) {
                    Label("Rezepte", systemImage: "fork.knife.circle.fill")
                }
                .tag(Tab.recipes) // Tag to link with selectedTab state.

                // NavigationLink for the Meal Planner section.
                NavigationLink(value: Tab.mealPlanner) {
                    Label("Mahlzeitenplaner", systemImage: "calendar")
                }
                .tag(Tab.mealPlanner)

                // New: NavigationLink for the Shopping List section.
                NavigationLink(value: Tab.shoppingList) {
                    Label("Einkaufsliste", systemImage: "cart.fill")
                }
                .tag(Tab.shoppingList)

                // NavigationLink for the Measurement Converter section.
                NavigationLink(value: Tab.converter) {
                    Label("Umrechner", systemImage: "arrow.left.arrow.right")
                }
                .tag(Tab.converter)

                // New: NavigationLink for Settings.
                NavigationLink(value: Tab.settings) {
                    Label("Einstellungen", systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
            }
            .listStyle(.sidebar) // Apply sidebar style for a native macOS look.
            .navigationTitle("Crouton") // Title for the sidebar.
        } detail: {
            // Detail view that changes based on the selected tab.
            switch selectedTab {
            case .recipes:
                // Display RecipeListView and inject the recipeStore as an environment object.
                RecipeListView()
                    .environmentObject(recipeStore)
            case .mealPlanner:
                // Display MealPlannerView and inject both recipeStore and mealPlannerStore.
                MealPlannerView()
                    .environmentObject(recipeStore)
                    .environmentObject(mealPlannerStore)
            case .shoppingList:
                // Display ShoppingListView and inject both stores.
                ShoppingListView()
                    .environmentObject(recipeStore)
                    .environmentObject(mealPlannerStore)
            case .converter:
                // Display MeasurementConverterView.
                MeasurementConverterView()
            case .settings:
                // Display SettingsView.
                SettingsView(customAccentColor: $customAccentColor)
            }
        }
        .accentColor(customAccentColor) // Apply the custom accent color to the entire app.
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

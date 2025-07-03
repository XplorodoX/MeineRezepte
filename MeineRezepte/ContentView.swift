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
    
    // FIX: The selected tab is now optional, which is required for the List selection binding.
    @State private var selectedTab: Tab? = .recipes

    // AppStorage for custom accent color.
    @AppStorage("appAccentColorData") private var appAccentColorData: Data = Data()

    // FIX: This binding now correctly handles the conversion between Color and Data,
    // resolving the "self is immutable" error.
    private var customAccentColorBinding: Binding<Color> {
        Binding<Color>(
            get: {
                if let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: appAccentColorData) {
                    return Color(uiColor)
                }
                return .blue // Default color
            },
            set: { newColor in
                if let encodedColor = try? NSKeyedArchiver.archivedData(withRootObject: UIColor(newColor), requiringSecureCoding: false) {
                    appAccentColorData = encodedColor
                }
            }
        )
    }
    
    // A simple computed property to easily get the current accent color.
    private var customAccentColor: Color {
        customAccentColorBinding.wrappedValue
    }

    // FIX: The Tab enum now conforms to Hashable, allowing it to be used with List's selection feature.
    enum Tab: Hashable {
        case recipes
        case mealPlanner
        case shoppingList
        case converter
        case settings
    }

    var body: some View {
        NavigationSplitView {
            // The List's selection binding now works correctly with the Hashable and optional Tab state.
            // This resolves the "'init(selection:content:)' is unavailable in iOS" error.
            List(selection: $selectedTab) {
                NavigationLink(value: Tab.recipes) {
                    Label("Rezepte", systemImage: "fork.knife.circle.fill")
                }

                NavigationLink(value: Tab.mealPlanner) {
                    Label("Mahlzeitenplaner", systemImage: "calendar")
                }

                NavigationLink(value: Tab.shoppingList) {
                    Label("Einkaufsliste", systemImage: "cart.fill")
                }

                NavigationLink(value: Tab.converter) {
                    Label("Umrechner", systemImage: "arrow.left.arrow.right")
                }

                NavigationLink(value: Tab.settings) {
                    Label("Einstellungen", systemImage: "gearshape.fill")
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Crouton")
        } detail: {
            // The detail view now safely unwraps the optional selected tab.
            if let selectedTab = selectedTab {
                switch selectedTab {
                case .recipes:
                    RecipeListView()
                        .environmentObject(recipeStore)
                case .mealPlanner:
                    MealPlannerView()
                        .environmentObject(recipeStore)
                        .environmentObject(mealPlannerStore)
                case .shoppingList:
                    ShoppingListView()
                        .environmentObject(recipeStore)
                        .environmentObject(mealPlannerStore)
                case .converter:
                    MeasurementConverterView()
                case .settings:
                    SettingsView(customAccentColor: customAccentColorBinding)
                }
            } else {
                // A default view shown when nothing is selected.
                Text("Bitte eine Kategorie auswählen.")
            }
        }
        .accentColor(customAccentColor)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

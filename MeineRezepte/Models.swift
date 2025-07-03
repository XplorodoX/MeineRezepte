//
//  Models.swift
//  MeineRezepte
//
//  Created by Florian Merlau on 03.07.25.
//

import SwiftUI
import Combine

// Represents a single recipe
struct Recipe: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var ingredients: String
    var instructions: String
    var servings: Double = 1.0
    var url: String?
    var imageName: String? // Vorschlag: Name für ein Bild im Asset-Katalog
}

// Represents a meal plan entry for a specific date and recipe
struct MealPlanEntry: Identifiable, Codable, Hashable {
    var id = UUID()
    var date: Date
    var recipeID: UUID
}

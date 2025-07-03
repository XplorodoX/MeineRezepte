//  MealPlannerView.swift
//  MeineRezepte
//
//  Created by Florian Merlau on 03.07.25.
//

import SwiftUI
import SwiftData

struct MealPlannerView: View {
    @EnvironmentObject var recipeStore: RecipeStore // Access recipe data to link with meal plan.
    @EnvironmentObject var mealPlannerStore: MealPlannerStore // Access meal plan data.
    @State private var selectedDate: Date = Date() // The date currently in focus for the week display.
    @State private var showingRecipePicker = false // Controls presentation of the recipe picker sheet.
    
    // NEU: Zustand für die Ansichtsauswahl
    @State private var plannerView: PlannerView = .week

    enum PlannerView: String, CaseIterable, Identifiable {
        case week = "Woche"
        case month = "Monat"
        var id: Self { self }
    }

    var body: some View {
        VStack {
            // NEU: Picker zur Auswahl der Ansicht
            Picker("Ansicht", selection: $plannerView) {
                ForEach(PlannerView.allCases) { view in
                    Text(view.rawValue).tag(view)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            Text(plannerView == .week ? "Wochenplan" : "Monatsplan")
                .font(.largeTitle)
                .padding(.bottom)
            
            // Logik zur Anzeige der entsprechenden Ansicht
            if plannerView == .week {
                WeekView(selectedDate: $selectedDate)
            } else {
                MonthView(selectedDate: $selectedDate)
            }
            
            // New: Auto-generate meal plan button.
            Button("Mahlzeitenplan automatisch generieren") {
                mealPlannerStore.autoGenerateMealPlan(from: recipeStore.recipes)
            }
            .padding(.top)
        }
    }
}

// NEU: Eigene Ansichten für Woche und Monat für bessere Lesbarkeit

struct WeekView: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        VStack {
             HStack {
                // Button to navigate to the previous week.
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .day, value: -7, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(BorderlessButtonStyle()) // Minimalist button style.

                Spacer()

                // Display the formatted date range for the current week.
                Text("\(formattedWeekRange(for: selectedDate))")
                    .font(.headline)
                    .frame(minWidth: 200)

                Spacer()

                // Button to navigate to the next week.
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .day, value: 7, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding(.horizontal)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(0..<7) { dayOffset in
                    // Calculate the date for each day in the current week.
                    let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: startOfWeek(for: selectedDate))!
                    // Display a MealDayView for each day.
                    MealDayView(date: date)
                }
            }
            .padding()
        }
    }
    
    // Helper function to get the start of the week (Monday).
    func startOfWeek(for date: Date) -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Set Monday as the first day of the week.
        // Get the components for year and week of year, then create a date from them.
        return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) ?? date
    }

    // Helper function to format the week range (e.g., "Jan 1 - Jan 7").
    func formattedWeekRange(for date: Date) -> String {
        let start = startOfWeek(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 6, to: start) ?? start // 6 days after start.
        let formatter = DateFormatter()
        formatter.dateStyle = .medium // Use medium style for date formatting.
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}

struct MonthView: View {
    @Binding var selectedDate: Date
    // Implementieren Sie hier die Monatsansicht, ähnlich der Wochenansicht
    var body: some View {
        Text("Monatsansicht (Implementierung erforderlich)")
            .font(.title)
            .foregroundColor(.gray)
    }
}

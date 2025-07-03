//  StepByStepRecipeView.swift
//  MeineRezepte
//
//  Created by Florian Merlau on 03.07.25.
//
import SwiftUI
import Vision // NEU

struct StepByStepRecipeView: View {
    @Environment(\.dismiss) var dismiss
    let instructions: String
    @State private var currentStepIndex: Int = 0

    // Split instructions into individual steps. Assumes steps are separated by newlines.
    var steps: [String] {
        instructions.split(separator: "\n").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
    }
    
    // NEU: Zustand für die Gesichtserkennung
    @State private var winkDetected = false

    var body: some View {
        VStack {
            Text("Schritt \(currentStepIndex + 1) von \(steps.count)")
                .font(.title2)
                .padding()

            if steps.indices.contains(currentStepIndex) {
                Text(steps[currentStepIndex])
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                Text("Keine Schritte verfügbar oder Ende erreicht.")
                    .font(.title)
                    .foregroundColor(.secondary)
                    .padding()
            }

            Spacer()

            HStack {
                Button(action: {
                    if currentStepIndex > 0 {
                        currentStepIndex -= 1
                    }
                }) {
                    Label("Zurück", systemImage: "arrow.backward.circle.fill")
                        .font(.title)
                }
                .disabled(currentStepIndex == 0)

                Spacer()

                Button(action: {
                    goToNextStep()
                }) {
                    Label(currentStepIndex == steps.count - 1 ? "Fertig" : "Weiter", systemImage: currentStepIndex == steps.count - 1 ? "checkmark.circle.fill" : "arrow.forward.circle.fill")
                        .font(.title)
                }
            }
            .padding()

            Button("Beenden") {
                dismiss()
            }
            .padding(.bottom)
        }
        .frame(minWidth: 500, minHeight: 400)
        .onAppear(perform: setupWinkDetection) // NEU
        .onChange(of: winkDetected) { wink in // NEU
            if wink {
                goToNextStep()
                winkDetected = false // Zurücksetzen
            }
        }
    }
    
    // NEU: Funktion zum Einrichten der Augenzwinkern-Erkennung
    private func setupWinkDetection() {
        // Hier würden Sie den Code für AVFoundation und Vision einfügen,
        // um die Kamera zu starten und die Gesichtserkennung zu beginnen.
        // Bei erkanntem Augenzwinkern setzen Sie `winkDetected = true`.
        print("Wink Detection Setup (Platzhalter)")
    }
    
    // NEU: Hilfsfunktion für den nächsten Schritt
    private func goToNextStep() {
        if currentStepIndex < steps.count - 1 {
            currentStepIndex += 1
        } else {
            dismiss() // Dismiss if it's the last step
        }
    }
}

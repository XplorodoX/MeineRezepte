import SwiftUI
import UIKit // Import UIKit

struct SettingsView: View {
    // Binden Sie die Akzentfarbe aus der ContentView
    @Binding var customAccentColor: Color

    var body: some View {
        Form {
            Section(header: Text("Darstellung")) {
                ColorPicker("Akzentfarbe", selection: $customAccentColor)

                // NEU: App-Icon ändern
                Button("App-Icon zu Rot ändern") {
                    changeAppIcon(to: "redIcon")
                }

                Button("App-Icon zu Grün ändern") {
                    changeAppIcon(to: "greenIcon")
                }

                Button("Standard-App-Icon wiederherstellen") {
                    changeAppIcon(to: nil)
                }
            }
        }
        .padding()
        .navigationTitle("Einstellungen")
    }

    // NEU: Funktion zum Ändern des App-Icons
    func changeAppIcon(to iconName: String?) {
        guard UIApplication.shared.supportsAlternateIcons else {
            print("Alternative Icons werden nicht unterstützt.")
            return
        }

        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                print("Fehler beim Ändern des Icons: \(error.localizedDescription)")
            } else {
                print("App-Icon erfolgreich geändert.")
            }
        }
    }
}

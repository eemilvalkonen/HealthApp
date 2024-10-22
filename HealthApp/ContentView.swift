import SwiftUI
import HealthKit

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Koti", systemImage: "house.fill")
                }
            AboutView()
                .tabItem {
                    Label("Tietoja Sovelluksesta", systemImage: "info.circle.fill")
                }
        }
    }
}

struct HomeView: View {
    @State private var authorizationGranted = false
    var body: some View {
        VStack {
            if authorizationGranted {
                // Näytetään tiedot, jos lupa on saatu
                HealthDataView()
            } else {
                // Näytetään luvan pyytäminen
                AuthorizationView(authorizationGranted: $authorizationGranted)
            }
        }
    }
}

struct AboutView: View {
    var body: some View {
        VStack {
            Text("Tietoja tästä sovelluksesta")
                .font(.title)
                .padding()

            Text("Tämä sovellus on rakennettu SwiftUI:lla.")
                .font(.body)
                .padding()
        }
    }
}

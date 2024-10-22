import SwiftUI

struct AuthorizationView: View {
    @Binding var authorizationGranted: Bool

    var body: some View {
        VStack {
            Text("Tervetuloa Health-sovellukseen!")
                .padding()

            Button(action: {
                HealthKitManager.shared.requestAuthorization { success, error in
                    if success {
                        DispatchQueue.main.async {
                            authorizationGranted = true
                        }
                    } else if let error = error {
                        print("Virhe: \(error.localizedDescription)")
                    }
                }
            }) {
                Text("Pyydä HealthKit-lupaa")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

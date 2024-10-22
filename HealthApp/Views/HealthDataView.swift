import SwiftUI
import HealthKit

// Määritellään HealthDataType enum
enum HealthDataType {
    case steps, calories, distance, heartRate
}

struct HealthDataView: View {
    @State private var stepCount: Double? = nil
    @State private var caloriesBurned: Double? = nil
    @State private var distance: Double? = nil
    @State private var heartRate: Double? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Terveystiedot tänään")
                    .font(.title)
                    .bold()

                healthDataElement(title: "Askeleet", value: stepCount.map { "\(Int($0))" } ?? "Ei tietoa saatavilla", dataType: .steps)
                healthDataElement(title: "Kulutetut kalorit", value: caloriesBurned.map { "\(Int($0)) kcal" } ?? "Ei tietoa saatavilla", dataType: .calories)
                healthDataElement(title: "Matka", value: distance.map { String(format: "%.2f km", $0) } ?? "Ei tietoa saatavilla", dataType: .distance)
                healthDataElement(title: "Syke", value: heartRate.map { "\(Int($0)) bpm" } ?? "Ei tietoa saatavilla", dataType: .heartRate)
            }
            .onAppear {
                fetchHealthData()
            }
            .padding()
        }
    }

    // Funktio terveystiedon elementin luomiseen
    func healthDataElement(title: String, value: String, dataType: HealthDataType) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                    Text(value)
                        .font(.subheadline)
                }
                Spacer()
                NavigationLink(destination: HealthDataDetailView(dataType: dataType)) { // Oletetaan että HealthDataDetailView on määritelty jossain muualla
                    Text("Näytä lisätiedot")
                        .font(.footnote)
                        .padding(8)
                        .background(Color.white)
                        .foregroundColor(.blue)
                        .cornerRadius(5)
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }

    // Terveystietojen haku
    func fetchHealthData() {
        HealthKitManager.shared.fetchStepCount { count, error in
            if let count = count {
                DispatchQueue.main.async {
                    self.stepCount = count
                }
            }
        }

        HealthKitManager.shared.fetchCaloriesBurned { calories, error in
            if let calories = calories {
                DispatchQueue.main.async {
                    self.caloriesBurned = calories
                }
            }
        }

        HealthKitManager.shared.fetchDistance { distance, error in
            if let distance = distance {
                DispatchQueue.main.async {
                    self.distance = distance / 1000  // Muutetaan kilometreiksi
                }
            }
        }

        HealthKitManager.shared.fetchHeartRate { heartRate, error in
            if let heartRate = heartRate {
                DispatchQueue.main.async {
                    self.heartRate = heartRate
                }
            }
        }
    }
}

import SwiftUI

struct HealthDataView: View {
    @State private var stepCount: Double? = nil
    @State private var caloriesBurned: Double? = nil
    @State private var distance: Double? = nil
    @State private var heartRate: Double? = nil
    
    @State private var showingStepDetail = false
    @State private var showingCaloriesDetail = false
    @State private var showingDistanceDetail = false
    @State private var showingHeartRateDetail = false
    
    @State private var lastUpdated: Date? = nil
    @State private var showingUpdatedNotification = false

    var body: some View {
        ZStack {
            // Sininen tausta koko ruudun peittämiseksi
            Color.blue.opacity(0.3)
                .edgesIgnoringSafeArea(.all) // Kattaa koko näytön

            ScrollView {
                VStack(spacing: 20) {
                    if showingUpdatedNotification {
                        Text("Terveystiedot ovat ajantasalla!")
                            .foregroundColor(.green)
                            .transition(.opacity)
                    }

                    // Otsikko ja päivitysikoni
                    HStack {
                        Text("Terveystiedot tänään")
                            .font(.title)
                            .bold()
                        Spacer()
                        
                        Button(action: {
                            fetchHealthData()  // Päivitetään terveystiedot
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.title2)
                        }
                    }
                    
                    // Viimeisin päivitysaika haalealla fontilla
                    if let lastUpdated = lastUpdated {
                        Text("Viimeisin päivitys: \(formattedDate(lastUpdated))")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }

                    // Terveystietojen esittely
                    VStack(spacing: 20) {
                        // Askeleet
                        HStack {
                            if let stepCount = stepCount {
                                Text("Askeleet: ")
                                + Text("\(Int(stepCount))").bold()
                            } else {
                                Text("Askeleet: Ei tietoa saatavilla")
                            }
                            Spacer()
                            Button(action: {
                                showingStepDetail = true
                            }) {
                                Image(systemName: "info.circle")
                                    .font(.title2)
                            }
                            .sheet(isPresented: $showingStepDetail) {
                                StepDetailView()
                            }
                        }

                        // Kalorit
                        HStack {
                            if let caloriesBurned = caloriesBurned {
                                Text("Kulutetut kalorit: ")
                                + Text("\(Int(caloriesBurned)) kcal").bold()
                            } else {
                                Text("Kulutetut kalorit: Ei tietoa saatavilla")
                            }
                            Spacer()
                            Button(action: {
                                showingCaloriesDetail = true
                            }) {
                                Image(systemName: "info.circle")
                                    .font(.title2)
                            }
                            .sheet(isPresented: $showingCaloriesDetail) {
                                CaloriesDetailView()
                            }
                        }

                        // Matka
                        HStack {
                            if let distance = distance {
                                Text("Matka: ")
                                + Text("\(String(format: "%.2f", distance)) km").bold()
                            } else {
                                Text("Matka: Ei tietoa saatavilla")
                            }
                            Spacer()
                            Button(action: {
                                showingDistanceDetail = true
                            }) {
                                Image(systemName: "info.circle")
                                    .font(.title2)
                            }
                            .sheet(isPresented: $showingDistanceDetail) {
                                Text("Matkan lisätiedot täällä")
                            }
                        }

                        // Syke
                        HStack {
                            if let heartRate = heartRate {
                                Text("Syke: ")
                                + Text("\(Int(heartRate)) bpm").bold()
                            } else {
                                Text("Syke: Ei tietoa saatavilla")
                            }
                            Spacer()
                            Button(action: {
                                showingHeartRateDetail = true
                            }) {
                                Image(systemName: "info.circle")
                                    .font(.title2)
                            }
                            .sheet(isPresented: $showingHeartRateDetail) {
                                Text("Sykkeen lisätiedot täällä")
                            }
                        }
                    }
                    .padding() // Sisällön pehmennys
                    .background(Color.blue.opacity(0.3)) // Sisällön taustalle pehmeä valkoinen kerros
                    .cornerRadius(10) // Pyöristetyt kulmat
                    .shadow(radius: 10) // Pehmeä varjo
                }
                .padding(30) // Varmistaa, että sisältö ei mene aivan reunoille
            }
        }
        .onAppear {
            fetchHealthData()
        }
    }

    // Terveystietojen haku
    func fetchHealthData() {
        HealthKitManager.shared.fetchStepCount { count, error in
            if let count = count {
                DispatchQueue.main.async {
                    self.stepCount = count
                    updateData() // Päivityksen jälkeen
                }
            }
        }

        HealthKitManager.shared.fetchCaloriesBurned { calories, error in
            if let calories = calories {
                DispatchQueue.main.async {
                    self.caloriesBurned = calories
                    updateData() // Päivityksen jälkeen
                }
            }
        }

        HealthKitManager.shared.fetchDistance { distance, error in
            if let distance = distance {
                DispatchQueue.main.async {
                    self.distance = distance / 1000  // Muutetaan kilometreiksi
                    updateData() // Päivityksen jälkeen
                }
            }
        }

        HealthKitManager.shared.fetchHeartRate { heartRate, error in
            if let heartRate = heartRate {
                DispatchQueue.main.async {
                    self.heartRate = heartRate
                    updateData() // Päivityksen jälkeen
                }
            }
        }
    }
    
    // Päivityksen jälkeinen toiminto
    func updateData() {
        self.lastUpdated = Date() // Tallennetaan päivityksen aika
        self.showUpdatedNotification() // Näytetään ilmoitus
    }
    
    // Näytetään ilmoitus hetkellisesti
    func showUpdatedNotification() {
        withAnimation {
            self.showingUpdatedNotification = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                self.showingUpdatedNotification = false
            }
        }
    }

    // Ajan muotoilu
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

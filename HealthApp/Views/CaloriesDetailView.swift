import SwiftUI
import HealthKit
import Charts

struct CaloriesDetailView: View {
    @State private var calorieData: [(date: Date, calories: Double)] = []
    private var healthStore = HKHealthStore()

    var body: some View {
        VStack {
            // Lista viimeisen 7 päivän kalorikulutuksesta
            List(calorieData, id: \.date) { data in
                HStack {
                    Text(formattedDate(data.date))
                    Spacer()
                    Text("\(Int(data.calories)) kcal")
                }
            }

            // Kaavio viimeisen 7 päivän kalorikulutuksesta
            Chart {
                ForEach(calorieData, id: \.date) { data in
                    LineMark(
                        x: .value("Date", data.date, unit: .day),
                        y: .value("Calories", data.calories)
                    )
                }
            }
            .frame(height: 200)
            .padding()
        }
        .onAppear {
            fetchCaloriesForLast7Days()
        }
    }

    private func fetchCaloriesForLast7Days() {
        let calorieType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        let now = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        var interval = DateComponents()
        interval.day = 1
        
        let query = HKStatisticsCollectionQuery(
            quantityType: calorieType,
            quantitySamplePredicate: nil,
            options: .cumulativeSum,
            anchorDate: startDate,
            intervalComponents: interval
        )
        
        query.initialResultsHandler = { _, result, error in
            guard let result = result else {
                print("Error fetching calories: \(String(describing: error))")
                return
            }
            
            var fetchedData: [(date: Date, calories: Double)] = []
            result.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                let calories = statistics.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                fetchedData.append((date: statistics.startDate, calories: calories))
            }
            
            DispatchQueue.main.async {
                calorieData = fetchedData
            }
        }
        
        healthStore.execute(query)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

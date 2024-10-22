import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()

    // Pyydä luvat HealthKitin käyttöön
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }

        let stepCount = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let activeEnergy = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let distanceWalkingRunning = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate)!

        let typesToRead: Set<HKObjectType> = [stepCount, activeEnergy, distanceWalkingRunning, heartRate]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            completion(success, error)
        }
    }

    // Askelmäärän haku
    func fetchStepCount(completion: @escaping (Double?, Error?) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        fetchTodayData(for: stepType, unit: HKUnit.count(), completion: completion)
    }

    // Kulutettujen kalorien haku
    func fetchCaloriesBurned(completion: @escaping (Double?, Error?) -> Void) {
        let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        fetchTodayData(for: calorieType, unit: HKUnit.kilocalorie(), completion: completion)
    }

    // Matkan haku
    func fetchDistance(completion: @escaping (Double?, Error?) -> Void) {
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        fetchTodayData(for: distanceType, unit: HKUnit.meter(), completion: completion)
    }

    // Sykkeen haku
    func fetchHeartRate(completion: @escaping (Double?, Error?) -> Void) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        fetchMostRecentData(for: heartRateType, unit: HKUnit(from: "count/min"), completion: completion)
    }

    // Yleinen funktio tietojen hakemiseen tältä päivältä
    private func fetchTodayData(for type: HKQuantityType, unit: HKUnit, completion: @escaping (Double?, Error?) -> Void) {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(nil, error)
                return
            }
            completion(sum.doubleValue(for: unit), nil)
        }

        healthStore.execute(query)
    }

    // Yleinen funktio uusimpien tietojen hakemiseen
    private func fetchMostRecentData(for type: HKQuantityType, unit: HKUnit, completion: @escaping (Double?, Error?) -> Void) {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, error in
            guard let result = results?.first as? HKQuantitySample else {
                completion(nil, error)
                return
            }
            completion(result.quantity.doubleValue(for: unit), nil)
        }

        healthStore.execute(query)
    }
}

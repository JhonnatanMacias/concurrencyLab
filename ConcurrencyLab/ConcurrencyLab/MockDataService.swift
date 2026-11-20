import Foundation

enum MockDataServiceError: Error {
    case simulatedFailure
}

struct MockDataService {
    func fetchProfile(simulateError: Bool = false) async throws -> Profile {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        if simulateError {
            throw MockDataServiceError.simulatedFailure
        }
        return Profile(name: "Ada Lovelace", description: "Exploradora de Swift Concurrency")
    }

    func fetchPhotos() async throws -> [LabPhoto] {
        try await Task.sleep(nanoseconds: 1_500_000_000)
        return [
            LabPhoto(id: 1, title: "Montañas", symbol: "mountain.2.fill"),
            LabPhoto(id: 2, title: "Atardecer", symbol: "sunset.fill"),
            LabPhoto(id: 3, title: "Naturaleza", symbol: "leaf.fill")
        ]
    }

    func fetchRecommendations() async throws -> [Recommendation] {
        try await Task.sleep(nanoseconds: 800_000_000)
        return [
            Recommendation(id: 1, title: "Structured Concurrency", description: "Una introducción a tareas estructuradas."),
            Recommendation(id: 2, title: "Actors", description: "Cómo proteger estado compartido.")
        ]
    }
}

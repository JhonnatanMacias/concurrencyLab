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
        let requests: [(photo: LabPhoto, delay: UInt64)] = [
            (LabPhoto(id: 1, title: "Montañas", symbol: "mountain.2.fill"), 1_500_000_000),
            (LabPhoto(id: 2, title: "Atardecer", symbol: "sunset.fill"), 500_000_000),
            (LabPhoto(id: 3, title: "Naturaleza", symbol: "leaf.fill"), 1_000_000_000)
        ]

        return try await withThrowingTaskGroup(
            of: LabPhoto.self,
            returning: [LabPhoto].self
        ) { group in
            for request in requests {
                group.addTask {
                    try await Task.sleep(nanoseconds: request.delay)
                    return request.photo
                }
            }

            var completedPhotos: [LabPhoto] = []
            for try await photo in group {
                completedPhotos.append(photo)
            }
            return completedPhotos
        }
    }

    func fetchRecommendations() async throws -> [Recommendation] {
        try await Task.sleep(nanoseconds: 800_000_000)
        return [
            Recommendation(id: 1, title: "Structured Concurrency", description: "Una introducción a tareas estructuradas."),
            Recommendation(id: 2, title: "Actors", description: "Cómo proteger estado compartido.")
        ]
    }
}

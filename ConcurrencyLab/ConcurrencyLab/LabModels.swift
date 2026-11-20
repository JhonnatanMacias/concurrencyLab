import Foundation

struct Profile {
    let name: String
    let description: String
}

struct LabPhoto: Identifiable, Sendable {
    let id: Int
    let title: String
    let symbol: String
}

struct Recommendation: Identifiable {
    let id: Int
    let title: String
    let description: String
}

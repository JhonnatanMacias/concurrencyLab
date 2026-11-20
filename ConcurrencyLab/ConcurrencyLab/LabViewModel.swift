import Combine

@MainActor
final class LabViewModel: ObservableObject {
    @Published private(set) var profileState: ResourceLoadState = .idle
    @Published private(set) var photosState: ResourceLoadState = .idle
    @Published private(set) var recommendationsState: ResourceLoadState = .idle

    @Published private(set) var profile: Profile?
    @Published private(set) var photos: [LabPhoto] = []
    @Published private(set) var recommendations: [Recommendation] = []

    private let dataService = MockDataService()

    var isLoading: Bool {
        profileState.isLoading || photosState.isLoading || recommendationsState.isLoading
    }

    func loadAll() async {
        guard !isLoading else { return }

        async let profileLoad: Void = loadProfile()
        async let photosLoad: Void = loadPhotos()
        async let recommendationsLoad: Void = loadRecommendations()

        _ = await (profileLoad, photosLoad, recommendationsLoad)
    }

    func loadProfile() async {
        profileState = .loading
        do {
            profile = try await dataService.fetchProfile()
            profileState = .loaded
        } catch {
            profileState = .failed
        }
    }

    func loadPhotos() async {
        photosState = .loading
        do {
            photos = try await dataService.fetchPhotos()
            photosState = .loaded
        } catch {
            photosState = .failed
        }
    }

    func loadRecommendations() async {
        recommendationsState = .loading
        do {
            recommendations = try await dataService.fetchRecommendations()
            recommendationsState = .loaded
        } catch {
            recommendationsState = .failed
        }
    }
}

enum ResourceLoadState {
    case idle
    case loading
    case loaded
    case failed

    var label: String {
        switch self {
        case .idle: "Pendiente"
        case .loading: "Cargando"
        case .loaded: "Listo"
        case .failed: "Error"
        }
    }

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}

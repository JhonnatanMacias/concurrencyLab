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
    private var profileTask: Task<Void, Never>?
    private var photosTask: Task<Void, Never>?
    private var recommendationsTask: Task<Void, Never>?
    private var loadAllTask: Task<Void, Never>?

    var isLoading: Bool {
        profileState.isLoading || photosState.isLoading || recommendationsState.isLoading
    }

    func startLoadAll() {
        guard !isLoading, loadAllTask == nil else { return }
        loadAllTask = Task {
            await loadAll()
            loadAllTask = nil
        }
    }

    func cancelAllLoads() {
        loadAllTask?.cancel()
        profileTask?.cancel()
        photosTask?.cancel()
        recommendationsTask?.cancel()
    }

    func startProfileLoad(simulateError: Bool = false) {
        guard !profileState.isLoading else { return }
        profileTask = Task { await loadProfile(simulateError: simulateError) }
    }

    func startPhotosLoad() {
        guard !photosState.isLoading else { return }
        photosTask = Task { await loadPhotos() }
    }

    func startRecommendationsLoad() {
        guard !recommendationsState.isLoading else { return }
        recommendationsTask = Task { await loadRecommendations() }
    }

    private func loadAll() async {
        async let profileLoad: Void = loadProfile()
        async let photosLoad: Void = loadPhotos()
        async let recommendationsLoad: Void = loadRecommendations()

        _ = await (profileLoad, photosLoad, recommendationsLoad)
    }

    private func loadProfile(simulateError: Bool = false) async {
        profileState = .loading
        do {
            profile = try await dataService.fetchProfile(simulateError: simulateError)
            profileState = .loaded
        } catch is CancellationError {
            profileState = .cancelled
        } catch {
            profileState = .failed
        }
    }

    private func loadPhotos() async {
        photosState = .loading
        do {
            photos = try await dataService.fetchPhotos()
            photosState = .loaded
        } catch is CancellationError {
            photosState = .cancelled
        } catch {
            photosState = .failed
        }
    }

    private func loadRecommendations() async {
        recommendationsState = .loading
        do {
            recommendations = try await dataService.fetchRecommendations()
            recommendationsState = .loaded
        } catch is CancellationError {
            recommendationsState = .cancelled
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
    case cancelled

    var label: String {
        switch self {
        case .idle: "Pendiente"
        case .loading: "Cargando"
        case .loaded: "Listo"
        case .failed: "Error"
        case .cancelled: "Cancelado"
        }
    }

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}

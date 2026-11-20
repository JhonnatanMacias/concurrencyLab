import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = LabViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    introduction

                    Button {
                        if viewModel.isLoading {
                            viewModel.cancelAllLoads()
                        } else {
                            viewModel.startLoadAll()
                        }
                    } label: {
                        Label(
                            viewModel.isLoading ? "Cancelar cargas" : "Cargar todo en paralelo",
                            systemImage: viewModel.isLoading ? "xmark.circle" : "arrow.clockwise"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Label(
                        "Cargas exitosas: \(viewModel.successfulLoadsCount)",
                        systemImage: "checkmark.circle"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    Button("Simular error al cargar el perfil") {
                        viewModel.startProfileLoad(simulateError: true)
                    }
                    .font(.subheadline)
                    .disabled(viewModel.isLoading)

                    VStack(spacing: 12) {
                        ResourceStatusCard(
                            title: "Perfil",
                            subtitle: "Información de la cuenta",
                            systemImage: "person.crop.circle",
                            state: viewModel.profileState,
                            detail: viewModel.profile.map { "\($0.name) · \($0.description)" },
                            actionTitle: "Cargar perfil",
                            action: { viewModel.startProfileLoad() },
                            cancelAction: { viewModel.cancelAllLoads() }
                        )

                        ResourceStatusCard(
                            title: "Fotografías",
                            subtitle: "TaskGroup: se muestran al terminar",
                            systemImage: "photo.on.rectangle.angled",
                            state: viewModel.photosState,
                            detail: viewModel.photos.map(\.title).joined(separator: " · ").nilIfEmpty,
                            actionTitle: "Cargar fotografías",
                            action: { viewModel.startPhotosLoad() },
                            cancelAction: { viewModel.cancelAllLoads() }
                        )

                        ResourceStatusCard(
                            title: "Recomendaciones",
                            subtitle: "Contenido para descubrir",
                            systemImage: "sparkles",
                            state: viewModel.recommendationsState,
                            detail: viewModel.recommendations.first?.title,
                            actionTitle: "Cargar recomendaciones",
                            action: { viewModel.startRecommendationsLoad() },
                            cancelAction: { viewModel.cancelAllLoads() }
                        )
                    }

                    Text("En este laboratorio")
                        .font(.headline)
                        .padding(.top, 4)

                    Label("async let y TaskGroup · concurrencia estructurada", systemImage: "checkmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
                .frame(maxWidth: 640, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Concurrency Lab")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var introduction: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Swift Concurrency")
                .font(.largeTitle.bold())
            Text("Carga una sección por separado o inicia las tres a la vez.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

private struct ResourceStatusCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let state: ResourceLoadState
    let detail: String?
    let actionTitle: String
    let action: () -> Void
    let cancelAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(.tint)
                    .frame(width: 48, height: 48)
                    .background(.tint.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.headline)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if state.isLoading {
                    ProgressView()
                } else {
                    Text(state.label)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(state.label == "Error" ? .red : .secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(uiColor: .systemGroupedBackground), in: Capsule())
                }
            }

            if let detail {
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Button(state.isLoading ? "Cancelar carga" : actionTitle) {
                if state.isLoading {
                    cancelAction()
                } else {
                    action()
                }
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}

#Preview {
    ContentView()
}

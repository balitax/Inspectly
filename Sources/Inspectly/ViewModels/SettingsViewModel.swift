//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation
import SwiftUI

// MARK: - Settings View Model

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var settings: AppSettings
    @Published var showClearConfirmation: Bool = false
    @Published var showImportPicker: Bool = false
    @Published var showExportSuccess: Bool = false
    @Published var exportMessage: String = ""
    @Published var newIgnoredHost: String = ""

    private let storageManager: StorageManagerProtocol
    private let exportManager: ExportManagerProtocol
    private let requestRepository: RequestRepositoryProtocol
    private let stubRepository: StubRepositoryProtocol

    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    init(
        settings: AppSettings = .default,
        storageManager: StorageManagerProtocol,
        exportManager: ExportManagerProtocol,
        requestRepository: RequestRepositoryProtocol,
        stubRepository: StubRepositoryProtocol
    ) {
        self.settings = settings
        self.storageManager = storageManager
        self.exportManager = exportManager
        self.requestRepository = requestRepository
        self.stubRepository = stubRepository
    }

    // MARK: - Settings Actions

    func saveSettings() async {
        do {
            try await storageManager.save(settings, forKey: "inspectly_settings")
            InspectlyURLProtocol.isLoggingEnabled = settings.isLoggingEnabled
        } catch {
            print("[Inspectly] Failed to save settings: \(error)")
        }
    }

    func loadSettings() async {
        do {
            if let loaded = try await storageManager.load(AppSettings.self, forKey: "inspectly_settings") {
                settings = loaded
                InspectlyURLProtocol.isLoggingEnabled = settings.isLoggingEnabled
            }
        } catch {
            print("[Inspectly] Failed to load settings: \(error)")
        }
    }

    // MARK: - Host Management

    func addIgnoredHost() {
        guard !newIgnoredHost.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let host = IgnoredHost(host: newIgnoredHost.trimmingCharacters(in: .whitespaces))
        settings.ignoredHosts.append(host)
        newIgnoredHost = ""
        Task { await saveSettings() }
    }

    func removeIgnoredHost(_ host: IgnoredHost) {
        settings.ignoredHosts.removeAll { $0.id == host.id }
        Task { await saveSettings() }
    }

    func toggleIgnoredHost(_ host: IgnoredHost) {
        if let index = settings.ignoredHosts.firstIndex(where: { $0.id == host.id }) {
            settings.ignoredHosts[index].isEnabled.toggle()
            Task { await saveSettings() }
        }
    }

    // MARK: - Clear & Export

    func clearLogs() async {
        await requestRepository.deleteAllRequests()
        showClearConfirmation = false
    }

    func exportLogs() async {
        do {
            let requests = await requestRepository.getAllRequests()
            let data = try await exportManager.exportRequests(requests)
            let size = ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file)
            exportMessage = "Exported \(requests.count) requests (\(size))"
            showExportSuccess = true
        } catch {
            exportMessage = "Export failed: \(error.localizedDescription)"
            showExportSuccess = true
        }
    }

    func exportStubs() async {
        do {
            let stubs = await stubRepository.getAllStubs()
            let data = try await exportManager.exportStubs(stubs)
            let size = ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file)
            exportMessage = "Exported \(stubs.count) stubs (\(size))"
            showExportSuccess = true
        } catch {
            exportMessage = "Export failed: \(error.localizedDescription)"
            showExportSuccess = true
        }
    }

    // MARK: - Mock

    static func mock() -> SettingsViewModel {
        SettingsViewModel(
            settings: MockSettings.default,
            storageManager: MockStorageManager(),
            exportManager: MockExportManager(),
            requestRepository: MockRequestRepository(),
            stubRepository: MockStubRepository()
        )
    }
}

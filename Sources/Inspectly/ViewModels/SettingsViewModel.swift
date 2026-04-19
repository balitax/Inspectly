//
//  SettingsViewModel.swift
//  Inspectly
//
//  Created by Agus Cahyono on 18/04/2026.
//  Copyright © 2026 Agus Cahyono. All rights reserved.
//
//  Inspectly is a premium, developer-first HTTP interception and mocking
//  library for iOS. It captures, inspects, and mocks network requests with
//  zero configuration and zero dependencies.
//
//  Compatible with URLSession, Alamofire, AFNetworking, and any networking
//  library built on top of Foundation networking.
//
//  Repository:
//  https://github.com/balitax/Inspectly
//

import Foundation
import SwiftUI

// MARK: - Settings View Model

@available(iOS 16.0, *)
@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var settings: AppSettings
    @Published var showClearConfirmation: Bool = false
    @Published var exportMessage: String = ""
    @Published var newIgnoredHost: String = ""
    @Published var shareURL: IdentifiableURL? = nil
    @Published var showExportError: Bool = false

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
            InspectlyURLProtocol.isStubEnabled = settings.areStubsEnabled
        } catch {
            print("[Inspectly] Failed to save settings: \(error)")
        }
    }

    func loadSettings() async {
        do {
            if let loaded = try await storageManager.load(AppSettings.self, forKey: "inspectly_settings") {
                settings = loaded
                InspectlyURLProtocol.isLoggingEnabled = settings.isLoggingEnabled
                InspectlyURLProtocol.isStubEnabled = settings.areStubsEnabled
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
            
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent("inspectly_logs_\(Int(Date().timeIntervalSince1970)).json")
            try data.write(to: fileURL)
            
            shareURL = IdentifiableURL(url: fileURL)
        } catch {
            exportMessage = "Export failed: \(error.localizedDescription)"
            showExportError = true
        }
    }

    func exportStubs() async {
        do {
            let stubs = await stubRepository.getAllStubs()
            let data = try await exportManager.exportStubs(stubs)
            
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent("inspectly_stubs_\(Int(Date().timeIntervalSince1970)).json")
            try data.write(to: fileURL)
            
            shareURL = IdentifiableURL(url: fileURL)
        } catch {
            exportMessage = "Export failed: \(error.localizedDescription)"
            showExportError = true
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

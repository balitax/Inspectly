//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation
import SwiftUI

// MARK: - Stub Filter Option

enum StubFilterOption: String, CaseIterable, Identifiable {
    case all = "All"
    case active = "Active"
    case inactive = "Inactive"

    var id: String { rawValue }
}

// MARK: - Stub Manager View Model

@MainActor
final class StubManagerViewModel: ObservableObject {
    @Published var stubs: [RequestStub] = []
    @Published var searchText: String = ""
    @Published var filterOption: StubFilterOption = .all
    @Published var methodFilter: HTTPMethodType?
    @Published var isLoading: Bool = false
    @Published var showingNewStub: Bool = false

    private let stubRepository: StubRepositoryProtocol

    init(stubRepository: StubRepositoryProtocol) {
        self.stubRepository = stubRepository
    }

    // MARK: - Data

    func loadStubs() async {
        isLoading = true
        stubs = await stubRepository.getAllStubs()
        isLoading = false
    }

    var filteredStubs: [RequestStub] {
        var filtered = stubs

        // Search
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            filtered = filtered.filter {
                $0.name.lowercased().contains(query) ||
                $0.pathDisplay.lowercased().contains(query) ||
                ($0.groupName?.lowercased().contains(query) ?? false)
            }
        }

        // Active/Inactive filter
        switch filterOption {
        case .all: break
        case .active: filtered = filtered.filter { $0.isEnabled }
        case .inactive: filtered = filtered.filter { !$0.isEnabled }
        }

        // Method filter
        if let method = methodFilter {
            filtered = filtered.filter { $0.matchRule.method == method }
        }

        return filtered
    }

    var groupedStubs: [(group: String, stubs: [RequestStub])] {
        let grouped = Dictionary(grouping: filteredStubs) { $0.groupName ?? "Ungrouped" }
        return grouped
            .map { (group: $0.key, stubs: $0.value) }
            .sorted { $0.group < $1.group }
    }

    var isEmpty: Bool {
        filteredStubs.isEmpty && !isLoading
    }

    // MARK: - Actions

    func toggleStub(_ stub: RequestStub) async {
        await stubRepository.toggleStub(stub.id, enabled: !stub.isEnabled)
        await loadStubs()
    }

    func deleteStub(_ stub: RequestStub) async {
        await stubRepository.deleteStub(stub.id)
        stubs.removeAll { $0.id == stub.id }
    }

    func duplicateStub(_ stub: RequestStub) async {
        _ = await stubRepository.duplicateStub(stub.id)
        await loadStubs()
    }

    func createNewStub() -> RequestStub {
        RequestStub(
            name: "New Stub",
            matchRule: StubMatchRule(method: .get, urlPath: "/api/"),
            scenarios: [
                StubScenario(
                    name: "Default",
                    response: StubResponse(
                        statusCode: 200,
                        jsonBody: "{\n  \n}"
                    ),
                    isActive: true
                )
            ]
        )
    }

    func saveStub(_ stub: RequestStub) async {
        if stubs.contains(where: { $0.id == stub.id }) {
            await stubRepository.updateStub(stub)
        } else {
            await stubRepository.addStub(stub)
        }
        await loadStubs()
    }

    // MARK: - Mock

    static func mock() -> StubManagerViewModel {
        let vm = StubManagerViewModel(stubRepository: MockStubRepository())
        vm.stubs = []
        return vm
    }
}

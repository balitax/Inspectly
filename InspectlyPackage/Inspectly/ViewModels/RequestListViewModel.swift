//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation
import SwiftUI

// MARK: - Sort Option

enum RequestSortOption: String, CaseIterable, Identifiable {
    case latest = "Latest"
    case oldest = "Oldest"
    case slowest = "Slowest"
    case fastest = "Fastest"
    case highestStatus = "Highest Status"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .latest: return "arrow.down.circle"
        case .oldest: return "arrow.up.circle"
        case .slowest: return "tortoise"
        case .fastest: return "hare"
        case .highestStatus: return "number.circle"
        }
    }
}

// MARK: - Filter Option

struct RequestFilter {
    var methods: Set<HTTPMethodType> = []
    var statusCodeRange: ClosedRange<Int>?
    var successOnly: Bool = false
    var errorOnly: Bool = false
    var stubbedOnly: Bool = false
    var favoritesOnly: Bool = false
    var pinnedOnly: Bool = false

    var isActive: Bool {
        !methods.isEmpty || statusCodeRange != nil || successOnly || errorOnly ||
        stubbedOnly || favoritesOnly || pinnedOnly
    }

    var activeCount: Int {
        var count = 0
        if !methods.isEmpty { count += 1 }
        if statusCodeRange != nil { count += 1 }
        if successOnly { count += 1 }
        if errorOnly { count += 1 }
        if stubbedOnly { count += 1 }
        if favoritesOnly { count += 1 }
        if pinnedOnly { count += 1 }
        return count
    }

    mutating func reset() {
        methods = []
        statusCodeRange = nil
        successOnly = false
        errorOnly = false
        stubbedOnly = false
        favoritesOnly = false
        pinnedOnly = false
    }
}

// MARK: - Request List View Model

@MainActor
final class RequestListViewModel: ObservableObject {
    @Published var requests: [NetworkRequest] = []
    @Published var groupedRequests: [RequestGroup] = []
    @Published var searchText: String = ""
    @Published var sortOption: RequestSortOption = .latest
    @Published var filter: RequestFilter = RequestFilter()
    @Published var isLoading: Bool = false
    @Published var showFilterSheet: Bool = false
    @Published var errorMessage: String?

    private let requestRepository: RequestRepositoryProtocol

    init(requestRepository: RequestRepositoryProtocol) {
        self.requestRepository = requestRepository
    }

    // MARK: - Data Loading

    func loadRequests() async {
        isLoading = true
        errorMessage = nil
        requests = await requestRepository.getAllRequests()
        applyFiltersAndSort()
        isLoading = false
    }

    func refresh() async {
        await loadRequests()
    }

    // MARK: - Filtering & Sorting

    func applyFiltersAndSort() {
        var filtered = requests

        // Search
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            filtered = filtered.filter {
                $0.url.lowercased().contains(query) ||
                $0.method.rawValue.lowercased().contains(query) ||
                $0.host.lowercased().contains(query) ||
                ($0.statusCode.map { String($0) } ?? "").contains(query)
            }
        }

        // Method filter
        if !filter.methods.isEmpty {
            filtered = filtered.filter { filter.methods.contains($0.method) }
        }

        // Status code range
        if let range = filter.statusCodeRange {
            filtered = filtered.filter {
                guard let code = $0.statusCode else { return false }
                return range.contains(code)
            }
        }

        // Boolean filters
        if filter.successOnly { filtered = filtered.filter { $0.isSuccess } }
        if filter.errorOnly { filtered = filtered.filter { $0.isError } }
        if filter.stubbedOnly { filtered = filtered.filter { $0.isStubbed } }
        if filter.favoritesOnly { filtered = filtered.filter { $0.isFavorite } }
        if filter.pinnedOnly { filtered = filtered.filter { $0.isPinned } }

        // Sort
        switch sortOption {
        case .latest:
            filtered.sort { $0.timestamp > $1.timestamp }
        case .oldest:
            filtered.sort { $0.timestamp < $1.timestamp }
        case .slowest:
            filtered.sort { ($0.duration ?? 0) > ($1.duration ?? 0) }
        case .fastest:
            filtered.sort { ($0.duration ?? Double.infinity) < ($1.duration ?? Double.infinity) }
        case .highestStatus:
            filtered.sort { ($0.statusCode ?? 0) > ($1.statusCode ?? 0) }
        }

        groupedRequests = RequestGroup.groupByDate(filtered)
    }

    // MARK: - Actions

    func deleteRequest(_ request: NetworkRequest) async {
        await requestRepository.deleteRequest(request.id)
        requests.removeAll { $0.id == request.id }
        applyFiltersAndSort()
    }

    func togglePin(_ request: NetworkRequest) async {
        var updated = request
        updated.isPinned.toggle()
        await requestRepository.updateRequest(updated)
        if let idx = requests.firstIndex(where: { $0.id == request.id }) {
            requests[idx] = updated
        }
        applyFiltersAndSort()
    }

    func toggleFavorite(_ request: NetworkRequest) async {
        var updated = request
        updated.isFavorite.toggle()
        await requestRepository.updateRequest(updated)
        if let idx = requests.firstIndex(where: { $0.id == request.id }) {
            requests[idx] = updated
        }
        applyFiltersAndSort()
    }

    func addTag(_ tag: RequestTag, to request: NetworkRequest) async {
        var updated = request
        if !updated.tags.contains(where: { $0.id == tag.id }) {
            updated.tags.append(tag)
            await requestRepository.updateRequest(updated)
            if let idx = requests.firstIndex(where: { $0.id == request.id }) {
                requests[idx] = updated
            }
        }
    }

    func clearFilter() {
        filter.reset()
        applyFiltersAndSort()
    }

    var totalFilteredCount: Int {
        groupedRequests.reduce(0) { $0 + $1.requests.count }
    }

    var isEmpty: Bool {
        groupedRequests.isEmpty && !isLoading
    }

    var hasActiveFilter: Bool {
        filter.isActive || !searchText.isEmpty
    }

    // MARK: - Mock

    static func mock() -> RequestListViewModel {
        let vm = RequestListViewModel(requestRepository: MockRequestRepository())
        vm.requests = MockRequests.all
        vm.applyFiltersAndSort()
        return vm
    }
}

//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation
import SwiftUI

// MARK: - Dashboard View Model

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var summary: DashboardSummary = DashboardSummary()
    @Published var recentRequests: [NetworkRequest] = []
    @Published var isLoading: Bool = false

    private let requestRepository: RequestRepositoryProtocol

    init(requestRepository: RequestRepositoryProtocol) {
        self.requestRepository = requestRepository
    }

    func loadData() async {
        isLoading = true
        let allRequests = await requestRepository.getAllRequests()
        summary = DashboardSummary.compute(from: allRequests)
        recentRequests = Array(
            allRequests.sorted { $0.timestamp > $1.timestamp }.prefix(5)
        )
        isLoading = false
    }

    var errorRate: Double {
        guard summary.totalRequests > 0 else { return 0 }
        return Double(summary.failedRequests) / Double(summary.totalRequests)
    }

    var topMethods: [(method: HTTPMethodType, count: Int)] {
        summary.methodDistribution
            .sorted { $0.value > $1.value }
            .map { (method: $0.key, count: $0.value) }
    }

    var hourlyData: [(hour: Int, count: Int)] {
        (0...23).map { hour in
            (hour: hour, count: summary.hourlyActivity[hour] ?? 0)
        }
    }

    // MARK: - Mock

    static func mock() -> DashboardViewModel {
        let vm = DashboardViewModel(requestRepository: MockRequestRepository())
        vm.summary = DashboardSummary.compute(from: MockRequests.all)
        vm.recentRequests = Array(MockRequests.all.prefix(5))
        return vm
    }
}

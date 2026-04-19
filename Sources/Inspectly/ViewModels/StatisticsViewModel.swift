//
//  StatisticsViewModel.swift
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

// MARK: - Statistics View Model

@available(iOS 16.0, *)
@MainActor
final class StatisticsViewModel: ObservableObject {
    @Published var summary: StatisticsSummary = StatisticsSummary()
    @Published var recentRequests: [NetworkRequest] = []
    @Published var isLoading: Bool = false

    private let requestRepository: RequestRepositoryProtocol

    init(requestRepository: RequestRepositoryProtocol) {
        self.requestRepository = requestRepository
    }

    func loadData() async {
        isLoading = true
        let allRequests = await requestRepository.getAllRequests()
        summary = StatisticsSummary.compute(from: allRequests)
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

    static func mock() -> StatisticsViewModel {
        let vm = StatisticsViewModel(requestRepository: MockRequestRepository())
        vm.summary = StatisticsSummary.compute(from: [])
        vm.recentRequests = []
        return vm
    }
}

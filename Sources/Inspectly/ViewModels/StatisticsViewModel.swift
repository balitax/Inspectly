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

@MainActor
final class StatisticsViewModel: ObservableObject {
    @Published var summary: StatisticsSummary = StatisticsSummary()
    @Published var recentRequests: [NetworkRequest] = []
    @Published var isLoading: Bool = false

    private let requestRepository: RequestRepositoryProtocol

    init(requestRepository: RequestRepositoryProtocol) {
        self.requestRepository = requestRepository
    }

    private var allRequests: [NetworkRequest] = []

    func loadData() async {
        isLoading = true
        let loaded = await requestRepository.getAllRequests()
        allRequests = loaded
        summary = StatisticsSummary.compute(from: loaded)
        recentRequests = Array(
            loaded.sorted { $0.timestamp > $1.timestamp }.prefix(5)
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

    // MARK: - Feature #4: Performance Heatmap

    var endpointPerformance: [(path: String, avgTime: TimeInterval, count: Int)] {
        var pathGroups: [String: [TimeInterval]] = [:]
        for req in allRequests {
            guard let duration = req.duration else { continue }
            let key = req.path.isEmpty ? req.url : req.path
            pathGroups[key, default: []].append(duration)
        }
        return pathGroups
            .map { (path: $0.key, avgTime: $0.value.reduce(0, +) / Double($0.value.count), count: $0.value.count) }
            .sorted { $0.avgTime > $1.avgTime }
            .prefix(5)
            .map { $0 }
    }

    // MARK: - Feature #5: Duplicate Detector

    var duplicateGroups: [(method: HTTPMethodType, path: String, count: Int)] {
        var groups: [String: (method: HTTPMethodType, path: String, count: Int)] = [:]
        for req in allRequests {
            let key = "\(req.method.rawValue)|\(req.url)"
            if let existing = groups[key] {
                groups[key] = (method: existing.method, path: existing.path, count: existing.count + 1)
            } else {
                let displayPath = req.path.isEmpty ? req.url : req.path
                groups[key] = (method: req.method, path: displayPath, count: 1)
            }
        }
        return groups
            .filter { $0.value.count > 1 }
            .map { (method: $0.value.method, path: $0.value.path, count: $0.value.count) }
            .sorted { $0.count > $1.count }
            .prefix(5)
            .map { $0 }
    }

    // MARK: - Feature #6: Response Size Warning

    private static let largeResponseThreshold: Int64 = 1_048_576

    var largeResponses: [NetworkRequest] {
        allRequests
            .filter { ($0.responseBody?.size ?? 0) >= Self.largeResponseThreshold }
            .sorted { ($0.responseBody?.size ?? 0) > ($1.responseBody?.size ?? 0) }
            .prefix(5)
            .map { $0 }
    }

    var largeResponseCount: Int {
        allRequests.filter { ($0.responseBody?.size ?? 0) >= Self.largeResponseThreshold }.count
    }

    // MARK: - Mock

    static func mock() -> StatisticsViewModel {
        let vm = StatisticsViewModel(requestRepository: MockRequestRepository())
        vm.summary = StatisticsSummary.compute(from: [])
        vm.recentRequests = []
        return vm
    }
}

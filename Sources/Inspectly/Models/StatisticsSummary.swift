//
//  StatisticsSummary.swift
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

// MARK: - Statistics Summary

public struct StatisticsSummary {
    let totalRequests: Int
    let failedRequests: Int
    let averageResponseTime: TimeInterval
    let pinnedRequests: Int
    let favoriteRequests: Int
    let stubbedRequests: Int
    let successRate: Double
    let requestsPerMinute: Double
    let latestRequest: NetworkRequest?
    let methodDistribution: [HTTPMethodType: Int]
    let statusDistribution: [Int: Int] // status code -> count
    let hourlyActivity: [Int: Int] // hour (0-23) -> count

    init(
        totalRequests: Int = 0,
        failedRequests: Int = 0,
        averageResponseTime: TimeInterval = 0,
        pinnedRequests: Int = 0,
        favoriteRequests: Int = 0,
        stubbedRequests: Int = 0,
        successRate: Double = 0,
        requestsPerMinute: Double = 0,
        latestRequest: NetworkRequest? = nil,
        methodDistribution: [HTTPMethodType: Int] = [:],
        statusDistribution: [Int: Int] = [:],
        hourlyActivity: [Int: Int] = [:]
    ) {
        self.totalRequests = totalRequests
        self.failedRequests = failedRequests
        self.averageResponseTime = averageResponseTime
        self.pinnedRequests = pinnedRequests
        self.favoriteRequests = favoriteRequests
        self.stubbedRequests = stubbedRequests
        self.successRate = successRate
        self.requestsPerMinute = requestsPerMinute
        self.latestRequest = latestRequest
        self.methodDistribution = methodDistribution
        self.statusDistribution = statusDistribution
        self.hourlyActivity = hourlyActivity
    }

    var formattedAverageTime: String {
        if averageResponseTime < 1 {
            return String(format: "%.0fms", averageResponseTime * 1000)
        }
        return String(format: "%.2fs", averageResponseTime)
    }

    var formattedSuccessRate: String {
        String(format: "%.1f%%", successRate * 100)
    }

    static func compute(from requests: [NetworkRequest]) -> StatisticsSummary {
        let total = requests.count
        let failed = requests.filter { $0.isError }.count
        let pinned = requests.filter { $0.isPinned }.count
        let favorites = requests.filter { $0.isFavorite }.count
        let stubbed = requests.filter { $0.isStubbed }.count

        let durations = requests.compactMap { $0.duration }
        let avgTime = durations.isEmpty ? 0 : durations.reduce(0, +) / Double(durations.count)

        let successRate = total > 0 ? Double(total - failed) / Double(total) : 0

        var methodDist: [HTTPMethodType: Int] = [:]
        for request in requests {
            methodDist[request.method, default: 0] += 1
        }

        var statusDist: [Int: Int] = [:]
        for request in requests {
            if let code = request.statusCode {
                statusDist[code, default: 0] += 1
            }
        }

        var hourlyActivity: [Int: Int] = [:]
        let calendar = Calendar.current
        for request in requests {
            let hour = calendar.component(.hour, from: request.timestamp)
            hourlyActivity[hour, default: 0] += 1
        }

        return StatisticsSummary(
            totalRequests: total,
            failedRequests: failed,
            averageResponseTime: avgTime,
            pinnedRequests: pinned,
            favoriteRequests: favorites,
            stubbedRequests: stubbed,
            successRate: successRate,
            requestsPerMinute: 0,
            latestRequest: requests.max(by: { $0.timestamp < $1.timestamp }),
            methodDistribution: methodDist,
            statusDistribution: statusDist,
            hourlyActivity: hourlyActivity
        )
    }
}

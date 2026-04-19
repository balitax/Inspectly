//
//  RequestDetailViewModel.swift
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

// MARK: - Request Detail Tab

@available(iOS 16.0, *)
enum RequestDetailTab: String, CaseIterable, Identifiable {
    case overview = "Overview"
    case headers = "Headers"
    case params = "Params"
    case requestBody = "Request"
    case responseBody = "Response"
    case export = "Export"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .overview: return "info.circle"
        case .headers: return "list.bullet.rectangle"
        case .params: return "questionmark.circle"
        case .requestBody: return "arrow.up.doc"
        case .responseBody: return "arrow.down.doc"
        case .export: return "square.and.arrow.up"
        }
    }
}

// MARK: - Request Detail View Model

@available(iOS 16.0, *)
@MainActor
final class RequestDetailViewModel: ObservableObject {
    @Published var request: NetworkRequest
    @Published var selectedTab: RequestDetailTab = .overview
    @Published var showShareSheet: Bool = false
    @Published var copiedToClipboard: Bool = false
    @Published var shareContent: String = ""
    @Published var createdStub: RequestStub?
    @Published var shareURL: IdentifiableURL? = nil

    private let exportManager: ExportManagerProtocol

    init(request: NetworkRequest, exportManager: ExportManagerProtocol = ExportManager()) {
        self.request = request
        self.exportManager = exportManager
    }

    // MARK: - Stub Actions

    func createStub() {
        createdStub = request.toStub()
    }

    // MARK: - Overview Data

    var overviewItems: [(label: String, value: String, icon: String)] {
        var items: [(String, String, String)] = [
            ("Method", request.method.rawValue, "network"),
            ("URL", request.url, "link"),
            ("Host", request.host, "server.rack"),
            ("Path", request.path, "arrow.right.circle"),
            ("Status", request.statusCodeDisplay, "number.circle"),
            ("Duration", request.formattedDuration, "clock"),
            ("Timestamp", request.timestamp.fullTimestamp, "calendar"),
        ]

        if let size = request.requestSize {
            items.append(("Request Size", ByteCountFormatter.string(fromByteCount: size, countStyle: .file), "arrow.up"))
        }

        if let size = request.responseSize {
            items.append(("Response Size", ByteCountFormatter.string(fromByteCount: size, countStyle: .file), "arrow.down"))
        }

        items.append(("Source", request.source.displayName, request.source.iconName))

        if request.isStubbed, let scenario = request.stubScenarioName {
            items.append(("Stub Scenario", scenario, "hammer.fill"))
        }

        if let error = request.errorMessage {
            items.append(("Error", error, "exclamationmark.triangle"))
        }

        return items
    }

    // MARK: - Copy Actions

    func copyCURL() {
        UIPasteboard.general.string = request.curlCommand
        showCopiedFeedback()
    }

    func copyJSONBody() {
        let body = request.responseBody?.prettyPrinted ?? request.requestBody?.prettyPrinted ?? ""
        UIPasteboard.general.string = body
        showCopiedFeedback()
    }

    func copyFullRequest() {
        var output = "=== Request ===\n"
        output += "\(request.method.rawValue) \(request.url)\n\n"

        output += "--- Request Headers ---\n"
        for header in request.requestHeaders {
            output += "\(header.key): \(header.value)\n"
        }

        if let body = request.requestBody?.rawString {
            output += "\n--- Request Body ---\n\(body)\n"
        }

        output += "\n=== Response ===\n"
        output += "Status: \(request.statusCodeDisplay)\n"
        output += "Duration: \(request.formattedDuration)\n\n"

        output += "--- Response Headers ---\n"
        for header in request.responseHeaders {
            output += "\(header.key): \(header.value)\n"
        }

        if let body = request.responseBody?.rawString {
            output += "\n--- Response Body ---\n\(body)\n"
        }

        UIPasteboard.general.string = output
        showCopiedFeedback()
    }

    func shareRequest() {
        shareContent = request.curlCommand
        showShareSheet = true
    }

    func shareAsJSON() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(request)
            
            let tempDir = FileManager.default.temporaryDirectory
            let fileName = "inspectly_request_\(request.method.rawValue)_\(Int(Date().timeIntervalSince1970)).json"
            let fileURL = tempDir.appendingPathComponent(fileName)
            try data.write(to: fileURL)
            
            shareURL = IdentifiableURL(url: fileURL)
        } catch {
            print("[Inspectly] Failed to share as JSON: \(error)")
        }
    }

    private func showCopiedFeedback() {
        copiedToClipboard = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.copiedToClipboard = false
        }
    }

    // MARK: - Formatted Data

    var prettyRequestBody: String {
        request.requestBody?.prettyPrinted ?? "No request body"
    }

    var prettyResponseBody: String {
        request.responseBody?.prettyPrinted ?? "No response body"
    }

    // MARK: - Mock

    static func mock() -> RequestDetailViewModel {
        RequestDetailViewModel(request: NetworkRequest(method: .get, url: "https://api.example.com", host: "api.example.com", path: "/"))
    }
}

//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation
import SwiftUI

// MARK: - Request Detail Tab

enum RequestDetailTab: String, CaseIterable, Identifiable {
    case overview = "Overview"
    case headers = "Headers"
    case params = "Params"
    case requestBody = "Request"
    case responseBody = "Response"
    case timeline = "Timeline"
    case export = "Export"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .overview: return "info.circle"
        case .headers: return "list.bullet.rectangle"
        case .params: return "questionmark.circle"
        case .requestBody: return "arrow.up.doc"
        case .responseBody: return "arrow.down.doc"
        case .timeline: return "clock.arrow.circlepath"
        case .export: return "square.and.arrow.up"
        }
    }
}

// MARK: - Request Detail View Model

@MainActor
final class RequestDetailViewModel: ObservableObject {
    @Published var request: NetworkRequest
    @Published var selectedTab: RequestDetailTab = .overview
    @Published var showShareSheet: Bool = false
    @Published var copiedToClipboard: Bool = false
    @Published var shareContent: String = ""

    private let exportManager: ExportManagerProtocol

    init(request: NetworkRequest, exportManager: ExportManagerProtocol = ExportManager()) {
        self.request = request
        self.exportManager = exportManager
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
        RequestDetailViewModel(request: MockRequests.postLogin)
    }
}

import SwiftUI
import Alamofire

struct DemoAppView: View {
    
    // MARK: - Network Engine
    
    private enum NetworkEngine: String, CaseIterable, Identifiable {
        case alamofire = "Alamofire"
        case urlSession = "URLSession"
        
        var id: String { rawValue }
    }
    
    // MARK: - State
    
    @State private var showingInspectly = false
    @State private var responseText = "Network request results will appear here."
    @State private var isLoading = false
    @State private var selectedNetworkEngine: NetworkEngine = .alamofire
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                // MARK: - Header Info
                
                VStack(spacing: 8) {
                    Image(systemName: "iphone.radiowaves.left.and.right")
                        .font(.system(size: 48))
                        .foregroundStyle(.indigo)
                        .padding(.bottom, 8)
                    
                    Text("Inspectly Demo")
                        .font(.title2.bold())
                    
                    Text("Shake your device (⌘+Ctrl+Z) to open Inspectly inspector.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 40)
                
                // MARK: - Network Engine Picker
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Network Engine")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    
                    Picker("Network Engine", selection: $selectedNetworkEngine) {
                        ForEach(NetworkEngine.allCases) { engine in
                            Text(engine.rawValue)
                                .tag(engine)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal, 24)
                
                // MARK: - Action Buttons
                
                VStack(spacing: 12) {
                    Button(action: loadCommentList) {
                        actionLabel(
                            "Fetch Comments",
                            icon: "message.circle.fill",
                            color: .blue
                        )
                    }
                    
                    Button(action: loadPostDetail) {
                        actionLabel(
                            "Fetch Post Detail",
                            icon: "doc.text.fill",
                            color: .green
                        )
                    }
                    
                    Button(action: loadInvalidEndpoint) {
                        actionLabel(
                            "Simulate 404 Error",
                            icon: "exclamationmark.triangle.fill",
                            color: .red
                        )
                    }
                }
                .padding(.horizontal, 24)
                
                // MARK: - Response Box
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Latest Response")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text(selectedNetworkEngine.rawValue)
                            .font(.caption2.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.tertiarySystemFill))
                            .clipShape(Capsule())
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                        
                        if isLoading {
                            VStack(spacing: 12) {
                                ProgressView()
                                
                                Text("Loading...")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            ScrollView {
                                Text(responseText)
                                    .font(.system(size: 12, design: .monospaced))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(12)
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Action Label UI
    
    private func actionLabel(
        _ title: String,
        icon: String,
        color: Color
    ) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
            
            Text(title)
                .fontWeight(.medium)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .opacity(0.5)
        }
        .padding()
        .foregroundStyle(.white)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    // MARK: - Network Actions
    
    private func loadCommentList() {
        requestJSON(
            from: "https://jsonplaceholder.typicode.com/comments?postId=1",
            loadingMessage: "Loading comments..."
        )
    }
    
    private func loadPostDetail() {
        requestJSON(
            from: "https://jsonplaceholder.typicode.com/posts/1",
            loadingMessage: "Loading post..."
        )
    }
    
    private func loadInvalidEndpoint() {
        requestJSON(
            from: "https://jsonplaceholder.typicode.com/invalid-endpoint-404",
            loadingMessage: "Loading invalid endpoint..."
        )
    }
    
    // MARK: - Request Handler
    
    private func requestJSON(
        from urlString: String,
        method: HTTPMethod = .get,
        loadingMessage: String = "Loading..."
    ) {
        isLoading = true
        responseText = loadingMessage
        
        switch selectedNetworkEngine {
        case .alamofire:
            performAlamofireRequest(
                from: urlString,
                method: method
            )
            
        case .urlSession:
            performURLSessionRequest(
                from: urlString,
                method: method
            )
        }
    }
    
    // MARK: - Alamofire Request
    
    private func performAlamofireRequest(
        from urlString: String,
        method: HTTPMethod
    ) {
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        AF.request(
            urlString,
            method: method,
            headers: headers
        )
        .validate()
        .responseData { response in
            isLoading = false
            
            switch response.result {
            case .success(let data):
                if let prettyJSON = String(data: data, encoding: .utf8)?.prettyPrintedJSON {
                    responseText = prettyJSON
                } else {
                    responseText = String(data: data, encoding: .utf8) ?? "Unable to parse response body"
                }
                
            case .failure(let error):
                let statusCode = response.response?.statusCode ?? 0
                let serverResponse = response.data.flatMap {
                    String(data: $0, encoding: .utf8)
                } ?? "No response body"
                
                responseText = """
                [Alamofire Request Failed]
                
                URL:
                \(urlString)
                
                Status Code:
                \(statusCode)
                
                Error:
                \(error.localizedDescription)
                
                Response:
                \(serverResponse)
                """
            }
        }
    }
    
    // MARK: - URLSession Request
    
    private func performURLSessionRequest(
        from urlString: String,
        method: HTTPMethod
    ) {
        guard let url = URL(string: urlString) else {
            isLoading = false
            responseText = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error {
                    responseText = """
                    [URLSession Request Failed]
                    
                    URL:
                    \(urlString)
                    
                    Error:
                    \(error.localizedDescription)
                    """
                    return
                }
                
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                
                guard let data else {
                    responseText = """
                    [URLSession Request Failed]
                    
                    URL:
                    \(urlString)
                    
                    Status Code:
                    \(statusCode)
                    
                    No data received
                    """
                    return
                }
                
                if let prettyJSON = String(data: data, encoding: .utf8)?.prettyPrintedJSON {
                    responseText = prettyJSON
                } else {
                    responseText = String(data: data, encoding: .utf8) ?? "Unable to parse response body"
                }
            }
        }
        .resume()
    }
}

#Preview {
    DemoAppView()
}

// MARK: - JSON Formatter Extension

extension String {
    var prettyPrintedJSON: String? {
        guard
            let data = data(using: .utf8),
            let jsonObject = try? JSONSerialization.jsonObject(with: data),
            let prettyData = try? JSONSerialization.data(
                withJSONObject: jsonObject,
                options: [.prettyPrinted, .sortedKeys]
            )
        else {
            return nil
        }
        
        return String(decoding: prettyData, as: UTF8.self)
    }
}

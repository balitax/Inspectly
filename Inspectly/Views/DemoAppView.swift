//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import SwiftUI

// MARK: - Demo App View

struct DemoAppView: View {
    @State private var showingInspectly = false
    @State private var responseText = "Network request results will appear here."
    @State private var isLoading = false
    
    private let container = DependencyContainer.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // MARK: - Header Info
                VStack(spacing: 8) {
                    Image(systemName: "iphone.radiowaves.left.and.right")
                        .font(.system(size: 48))
                        .foregroundStyle(.accentColor)
                        .padding(.bottom, 8)
                    
                    Text("Inspectly Demo App")
                        .font(.title2.bold())
                    
                    Text("Shake your device (or simulator: ⌘+⌃+Z) to open the Inspectly debug menu.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 40)
                
                // MARK: - Action Buttons
                VStack(spacing: 12) {
                    Button(action: fetchUsers) {
                        actionLabel("Fetch Users", icon: "person.2.fill", color: .blue)
                    }
                    
                    Button(action: fetchPosts) {
                        actionLabel("Fetch Posts", icon: "doc.text.fill", color: .green)
                    }
                    
                    Button(action: triggerError) {
                        actionLabel("Simulate 404 Error", icon: "exclamationmark.triangle.fill", color: .red)
                    }
                }
                .padding(.horizontal, 24)
                
                // MARK: - Response Box
                VStack(alignment: .leading) {
                    Text("Latest Response")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                        
                        if isLoading {
                            ProgressView()
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
                .padding(24)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingInspectly = true
                    } label: {
                        Image(systemName: "ladybug.fill")
                            .foregroundStyle(.orange)
                    }
                }
            }
        }
        .onShake {
            Task {
                let settings = try? await container.storageManager.load(AppSettings.self, forKey: "inspectly_settings")
                // Only trigger if setting is enabled (defaults to true)
                await MainActor.run {
                    if settings?.isShakeGestureEnabled ?? true {
                        showingInspectly = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingInspectly) {
            // Presenting the main Inspectly dashboard
            ContentView(container: container)
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Action Label UI
    
    private func actionLabel(_ title: String, icon: String, color: Color) -> some View {
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
    
    private func fetchUsers() {
        performRequest(url: "https://jsonplaceholder.typicode.com/users")
    }
    
    private func fetchPosts() {
        performRequest(url: "https://jsonplaceholder.typicode.com/posts/1")
    }
    
    private func triggerError() {
        performRequest(url: "https://jsonplaceholder.typicode.com/invalid-endpoint-404")
    }
    
    private func performRequest(url urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        isLoading = true
        responseText = "Loading..."
        
        // This is a standard URLSession call.
        // It will be completely intercepted and recorded by InspectlyURLProtocol
        // because we registered it in the AppDelegate/App init.
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.responseText = "Error: \(error.localizedDescription)"
                    return
                }
                
                if let data = data {
                    if let prettyJSON = String(data: data, encoding: .utf8)?.prettyPrintedJSON {
                        self.responseText = prettyJSON
                    } else {
                        self.responseText = String(data: data, encoding: .utf8) ?? "Invalid text data"
                    }
                }
            }
        }.resume()
    }
}

#Preview {
    DemoAppView()
}

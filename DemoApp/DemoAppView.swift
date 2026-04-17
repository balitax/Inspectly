//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import SwiftUI
import Alamofire

struct DemoAppView: View {
    @State private var showingInspectly = false
    @State private var responseText = "Alamofire network results will appear here."
    @State private var isLoading = false
    
    // We pass these from the App entry point
    let session: Session
    let container: DependencyContainer

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // MARK: - Header Info
                VStack(spacing: 8) {
                    Image(systemName: "iphone.radiowaves.left.and.right")
                        .font(.system(size: 48))
                        .foregroundStyle(.accentColor)
                        .padding(.bottom, 8)
                    
                    Text("Alamofire Demo App")
                        .font(.title2.bold())
                    
                    Text("Shake your device to open Inspectly and monitor the Alamofire calls underneath.")
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
                await MainActor.run {
                    if settings?.isShakeGestureEnabled ?? true {
                        showingInspectly = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingInspectly) {
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
    
    // MARK: - Alamofire Network Actions
    
    private func fetchUsers() {
        performAlamofireRequest(url: "https://jsonplaceholder.typicode.com/users")
    }
    
    private func fetchPosts() {
        performAlamofireRequest(url: "https://jsonplaceholder.typicode.com/posts/1")
    }
    
    private func triggerError() {
        performAlamofireRequest(url: "https://jsonplaceholder.typicode.com/invalid-endpoint-404")
    }
    
    private func performAlamofireRequest(url: String) {
        isLoading = true
        responseText = "Loading via Alamofire..."
        
        session.request(url, method: .get, headers: ["Accept": "application/json"])
            .validate()
            .responseData { response in
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    switch response.result {
                    case .success(let data):
                        if let prettyJSON = String(data: data, encoding: .utf8)?.prettyPrintedJSON {
                            self.responseText = prettyJSON
                        } else {
                            self.responseText = String(data: data, encoding: .utf8) ?? "Invalid text data"
                        }
                    case .failure(let error):
                        self.responseText = "Error: \(error.localizedDescription)"
                    }
                }
            }
    }
}

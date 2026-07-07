//
//  HTMLPreviewView.swift
//  Inspectly
//
//  Created by Gemini CLI on 21/04/2026.
//

import SwiftUI
import WebKit

@available(iOS 16.0, *)
struct HTMLPreviewView: View {
    let htmlContent: String
    @State private var webViewHeight: CGFloat = 300
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("HTML Preview")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
            
            HTMLWebView(html: htmlContent, dynamicHeight: $webViewHeight)
                .frame(height: webViewHeight)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )
        }
    }
}

@available(iOS 16.0, *)
struct HTMLWebView: UIViewRepresentable {
    let html: String
    @Binding var dynamicHeight: CGFloat
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        
        webView.backgroundColor = .white
        webView.isOpaque = true
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Prevent infinite reload loop: Only load if content actually changed
        guard context.coordinator.lastLoadedHTML != html else { return }
        context.coordinator.lastLoadedHTML = html
        
        let wrappedHtml: String
        
        if html.lowercased().contains("<html") {
            if html.lowercased().contains("<head>") {
                wrappedHtml = html.replacingOccurrences(
                    of: "<head>",
                    with: "<head><meta name='viewport' content='width=device-width, initial-scale=1.0, shrink-to-fit=no'>",
                    options: .caseInsensitive
                )
            } else {
                wrappedHtml = html.replacingOccurrences(
                    of: "<html>",
                    with: "<html><head><meta name='viewport' content='width=device-width, initial-scale=1.0, shrink-to-fit=no'></head>",
                    options: .caseInsensitive
                )
            }
        } else {
            wrappedHtml = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
                <style>
                    body { 
                        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                        padding: 16px;
                        margin: 0;
                        word-wrap: break-word;
                    }
                </style>
            </head>
            <body>
                \(html)
            </body>
            </html>
            """
        }
        
        uiView.loadHTMLString(wrappedHtml, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: HTMLWebView
        var lastLoadedHTML: String?
        
        init(_ parent: HTMLWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Measure height after load
            webView.evaluateJavaScript("document.documentElement.scrollHeight") { (height, error) in
                if let height = height as? CGFloat, height > 0 {
                    DispatchQueue.main.async {
                        if abs(self.parent.dynamicHeight - height) > 1 {
                            self.parent.dynamicHeight = height
                        }
                    }
                }
            }
        }
    }
}

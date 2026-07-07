//
//  ResponseEditorView.swift
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

import SwiftUI

// MARK: - Response Editor View

@available(iOS 16.0, *)
struct ResponseEditorView: View {
    @ObservedObject var viewModel: StubDetailViewModel
    
    var body: some View {
        VStack(spacing: 14) {
            // MARK: - Status Code
            VStack(alignment: .leading, spacing: 4) {
                Text("Status Code")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 8) {
                    TextField("200", value: $viewModel.response.statusCode, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 14, design: .monospaced))
                        .frame(width: 80)
                        .keyboardType(.numberPad)
                    
                    StatusBadgeView(statusCode: viewModel.response.statusCode)
                    
                    Spacer()
                    
                    // Quick status buttons
                    ForEach([200, 201, 400, 404, 500], id: \.self) { code in
                        Button {
                            viewModel.response.statusCode = code
                        } label: {
                            Text("\(code)")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(viewModel.response.statusCode == code ? Color.accentColor.opacity(0.15) : Color(.tertiarySystemFill))
                                .foregroundColor(viewModel.response.statusCode == code ? .accentColor : .secondary)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            Divider()
            
            // MARK: - Response Delay
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Response Delay")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "%.1fs", viewModel.response.responseDelay))
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.accentColor)
                }
                
                Slider(value: $viewModel.response.responseDelay, in: 0...30, step: 0.5)
                    .tint(.accentColor)
            }
            
            Divider()
            
            // MARK: - Error Simulation
            VStack(alignment: .leading, spacing: 8) {
                Text("Error Simulation")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 6) {
                    ForEach(StubErrorType.allCases) { errorType in
                        Button {
                            viewModel.response.errorType = errorType
                            if let code = errorType.statusCode {
                                viewModel.response.statusCode = code
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: errorType.iconName)
                                    .font(.system(size: 9))
                                Text(errorType.displayName)
                                    .font(.system(size: 10, weight: .medium))
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 7)
                            .padding(.horizontal, 6)
                            .background(viewModel.response.errorType == errorType ? Color.accentColor.opacity(0.15) : Color(.tertiarySystemFill))
                            .foregroundColor(viewModel.response.errorType == errorType ? .accentColor : .secondary)
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            Divider()
            
            // MARK: - JSON Body Editor
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("JSON Response Body")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    if let error = viewModel.jsonValidationError {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.red)
                    } else if viewModel.response.jsonBody?.isEmpty == false {
                        Label("Valid", systemImage: "checkmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.green)
                    }
                }
                
                TextEditor(text: Binding(
                    get: { viewModel.response.jsonBody ?? "" },
                    set: { viewModel.response.jsonBody = $0.isEmpty ? nil : $0 }
                ))
                .font(.system(size: 12, design: .monospaced))
                .frame(minHeight: 150)
                .padding(4)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .onChange(of: viewModel.response.jsonBody) { _ in
                    viewModel.validateJSON()
                }
            }
        }
    }
}

// MARK: - Preview

@available(iOS 16.0, *)
struct ResponseEditorView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            ResponseEditorView(viewModel: .mock())
                .padding()
        }
    }
}

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
    @Binding var response: StubResponse
    var onValidateJSON: () -> Void
    var jsonError: String?
    
    var body: some View {
        VStack(spacing: 14) {
            // MARK: - Status Code
            VStack(alignment: .leading, spacing: 4) {
                Text("Status Code")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 8) {
                    TextField("200", value: $response.statusCode, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 14, design: .monospaced))
                        .frame(width: 80)
                        .keyboardType(.numberPad)
                    
                    StatusBadgeView(statusCode: response.statusCode)
                    
                    Spacer()
                    
                    // Quick status buttons
                    ForEach([200, 201, 400, 404, 500], id: \.self) { code in
                        Button {
                            response.statusCode = code
                        } label: {
                            Text("\(code)")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(response.statusCode == code ? Color.accentColor.opacity(0.15) : Color(.tertiarySystemFill))
                                .foregroundColor(response.statusCode == code ? .accentColor : .secondary)
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
                    Text(String(format: "%.1fs", response.responseDelay))
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.accentColor)
                }
                
                Slider(value: $response.responseDelay, in: 0...30, step: 0.5)
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
                            response.errorType = errorType
                            if let code = errorType.statusCode {
                                response.statusCode = code
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
                            .background(response.errorType == errorType ? Color.accentColor.opacity(0.15) : Color(.tertiarySystemFill))
                            .foregroundColor(response.errorType == errorType ? .accentColor : .secondary)
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
                    
                    if let error = jsonError {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.red)
                    } else if response.jsonBody?.isEmpty == false {
                        Label("Valid", systemImage: "checkmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.green)
                    }
                }
                
                TextEditor(text: Binding(
                    get: { response.jsonBody ?? "" },
                    set: { response.jsonBody = $0.isEmpty ? nil : $0 }
                ))
                .font(.system(size: 12, design: .monospaced))
                .frame(minHeight: 150)
                .padding(4)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .onChange(of: response.jsonBody) { _ in
                    onValidateJSON()
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
            ResponseEditorView(
                response: .constant(StubResponse(
                    statusCode: 200,
                    jsonBody: "{\n  \"message\": \"Hello\"\n}"
                )),
                onValidateJSON: {},
                jsonError: nil
            )
            .padding()
        }
    }
}

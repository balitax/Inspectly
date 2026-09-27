//
//  SwiftCodeGenerator.swift
//  Inspectly
//
//  Created by OpenCode on 27/09/2026.
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

// MARK: - Swift Code Generator

/// Generates a Swift Codable model from a JSON string.
enum SwiftCodeGenerator {
    /// Generate a Swift struct from JSON. Returns nil if JSON is invalid.
    static func generateModel(from jsonString: String, rootName: String = "GeneratedModel") -> String? {
        guard let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) else {
            return nil
        }

        var nestedStructs: [String] = []
        let properties = generateProperties(json: json, parentName: rootName, nestedStructs: &nestedStructs)

        var output = ""
        for nested in nestedStructs.reversed() {
            output += nested + "\n\n"
        }
        output += "struct \(rootName): Codable {\n"
        output += properties.indent()
        output += "}"
        return output
    }

    // MARK: - Private

    private static func generateProperties(
        json: Any,
        parentName: String,
        nestedStructs: inout [String]
    ) -> String {
        guard let object = json as? [String: Any] else {
            return ""
        }

        var properties: [String] = []
        var codingKeys: [(swift: String, json: String)] = []

        for (key, value) in object.sorted(by: { $0.key < $1.key }) {
            let swiftKey = key.toCamelCase()
            let type = swiftType(
                for: value,
                key: key,
                parentName: parentName,
                nestedStructs: &nestedStructs
            )

            if value is NSNull {
                properties.append("var \(swiftKey): \(type) = nil")
            } else {
                properties.append("let \(swiftKey): \(type)")
            }

            codingKeys.append((swift: swiftKey, json: key))
        }

        var output = properties.joined(separator: "\n")
        output += "\n\n"
        output += "enum CodingKeys: String, CodingKey {\n"
        for pair in codingKeys {
            output += "    case \(pair.swift) = \"\(pair.json)\"\n"
        }
        output += "}"
        return output
    }

    private static func swiftType(
        for value: Any,
        key: String,
        parentName: String,
        nestedStructs: inout [String]
    ) -> String {
        switch value {
        case is NSNull:
            return "String?"
        case let string as String:
            if ISO8601DateFormatter().date(from: string) != nil {
                return "Date"
            }
            return "String"
        case let number as NSNumber:
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return "Bool"
            }
            let double = number.doubleValue
            return double == floor(double) ? "Int" : "Double"
        case let array as [Any]:
            guard let first = array.first else { return "[String]" }
            let elementType = swiftType(
                for: first,
                key: key,
                parentName: parentName,
                nestedStructs: &nestedStructs
            )
            return "[\(elementType)]"
        case let object as [String: Any]:
            let structName = parentName + key.capitalizedFirstLetter()
            let body = generateProperties(json: object, parentName: structName, nestedStructs: &nestedStructs)
            let structCode = "struct \(structName): Codable {\n" + body.indent() + "}"
            nestedStructs.append(structCode)
            return structName
        default:
            return "String"
        }
    }
}

// MARK: - String Helpers

private extension String {
    func toCamelCase() -> String {
        let components = self.split(separator: "_").map { String($0) }
        guard let first = components.first else { return self }
        let rest = components.dropFirst().map { $0.capitalizedFirstLetter() }
        return first.lowercasedFirstLetter() + rest.joined()
    }

    func capitalizedFirstLetter() -> String {
        guard let first = first else { return self }
        return String(first).uppercased() + dropFirst()
    }

    func lowercasedFirstLetter() -> String {
        guard let first = first else { return self }
        return String(first).lowercased() + dropFirst()
    }

    func indent() -> String {
        self.split(separator: "\n", omittingEmptySubsequences: false)
            .map { $0.isEmpty ? "" : "    \($0)" }
            .joined(separator: "\n") + "\n"
    }
}

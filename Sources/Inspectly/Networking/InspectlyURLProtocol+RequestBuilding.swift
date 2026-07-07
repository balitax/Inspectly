//
//  InspectlyURLProtocol+RequestBuilding.swift
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

// MARK: - Request Building

extension InspectlyURLProtocol {
    func buildNetworkRequest(from urlRequest: URLRequest, bodyData: Data?, timestamp: Date) -> NetworkRequest {
        let url = urlRequest.url?.absoluteString ?? ""
        let components = URLComponents(string: url)

        let requestHeaders = urlRequest.allHTTPHeaderFields?.map {
            RequestHeader(key: $0.key, value: $0.value)
        } ?? []

        let queryParams = components?.queryItems?.map {
            QueryParameter(key: $0.name, value: $0.value ?? "")
        } ?? []

        let contentType = urlRequest.contentType
        var requestBody: RequestBody?
        if let bodyData = bodyData {
            requestBody = RequestBody(
                rawString: String(data: bodyData, encoding: .utf8),
                rawData: bodyData,
                contentType: contentType,
                size: Int64(bodyData.count)
            )
        }

        return NetworkRequest(
            method: HTTPMethodType(rawValue: urlRequest.httpMethod ?? "GET") ?? .get,
            url: url,
            host: components?.host ?? "",
            path: components?.path ?? "",
            scheme: components?.scheme ?? "https",
            requestHeaders: requestHeaders,
            queryParameters: queryParams,
            requestBody: requestBody,
            requestContentType: contentType,
            requestSize: bodyData != nil ? Int64(bodyData!.count) : nil,
            timestamp: timestamp
        )
    }
}

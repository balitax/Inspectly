//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation

// MARK: - Mock Requests

struct MockRequests {

    // MARK: - Standard Headers

    static let standardRequestHeaders: [RequestHeader] = [
        RequestHeader(key: "Accept", value: "application/json"),
        RequestHeader(key: "Content-Type", value: "application/json"),
        RequestHeader(key: "Authorization", value: "Bearer eyJhbGciOiJIUzI1NiIs..."),
        RequestHeader(key: "User-Agent", value: "Inspectly/1.0 iOS/17.0"),
        RequestHeader(key: "Accept-Language", value: "en-US"),
        RequestHeader(key: "X-Request-ID", value: "req_abc123def456")
    ]

    static let standardResponseHeaders: [RequestHeader] = [
        RequestHeader(key: "Content-Type", value: "application/json; charset=utf-8"),
        RequestHeader(key: "Content-Length", value: "1234"),
        RequestHeader(key: "Date", value: "Thu, 17 Apr 2025 10:30:00 GMT"),
        RequestHeader(key: "Server", value: "nginx/1.21.0"),
        RequestHeader(key: "X-Request-ID", value: "req_abc123def456"),
        RequestHeader(key: "X-RateLimit-Limit", value: "100"),
        RequestHeader(key: "X-RateLimit-Remaining", value: "98"),
        RequestHeader(key: "Cache-Control", value: "no-cache")
    ]

    // MARK: - Timeline Events

    static func makeTimeline(start: Date, duration: TimeInterval) -> [TimelineEvent] {
        [
            TimelineEvent(name: "DNS Lookup", timestamp: start, duration: 0.012, detail: "api.example.com → 104.21.42.55"),
            TimelineEvent(name: "TCP Connection", timestamp: start.addingTimeInterval(0.012), duration: 0.025, detail: "TLS 1.3"),
            TimelineEvent(name: "TLS Handshake", timestamp: start.addingTimeInterval(0.037), duration: 0.034, detail: "ECDHE-RSA-AES256"),
            TimelineEvent(name: "Request Sent", timestamp: start.addingTimeInterval(0.071), duration: 0.003, detail: nil),
            TimelineEvent(name: "Waiting (TTFB)", timestamp: start.addingTimeInterval(0.074), duration: duration - 0.1, detail: nil),
            TimelineEvent(name: "Content Download", timestamp: start.addingTimeInterval(duration - 0.026), duration: 0.026, detail: "1.2 KB")
        ]
    }

    // MARK: - GET /users

    static let getUsersList = NetworkRequest(
        method: .get,
        url: "https://api.example.com/v1/users?page=1&limit=20",
        host: "api.example.com",
        path: "/v1/users",
        scheme: "https",
        statusCode: 200,
        requestHeaders: standardRequestHeaders,
        responseHeaders: standardResponseHeaders,
        queryParameters: [
            QueryParameter(key: "page", value: "1"),
            QueryParameter(key: "limit", value: "20")
        ],
        responseBody: ResponseBody(
            rawString: """
            {
              "data": [
                {"id": 1, "name": "Alice Johnson", "email": "alice@example.com", "role": "admin"},
                {"id": 2, "name": "Bob Smith", "email": "bob@example.com", "role": "user"},
                {"id": 3, "name": "Carol Williams", "email": "carol@example.com", "role": "user"}
              ],
              "meta": {"page": 1, "limit": 20, "total": 42}
            }
            """,
            contentType: .json,
            size: 342
        ),
        duration: 0.234,
        requestSize: 256,
        responseSize: 342,
        timestamp: .mockDate(minutesAgo: 2),
        completedAt: .mockDate(minutesAgo: 2).addingTimeInterval(0.234),
        status: .success,
        tags: [.api],
        timelineEvents: makeTimeline(start: .mockDate(minutesAgo: 2), duration: 0.234)
    )

    // MARK: - GET /users/123

    static let getUserDetail = NetworkRequest(
        method: .get,
        url: "https://api.example.com/v1/users/123",
        host: "api.example.com",
        path: "/v1/users/123",
        scheme: "https",
        statusCode: 200,
        requestHeaders: standardRequestHeaders,
        responseHeaders: standardResponseHeaders,
        responseBody: ResponseBody(
            rawString: """
            {
              "id": 123,
              "name": "John Doe",
              "email": "john.doe@example.com",
              "avatar": "https://api.example.com/avatars/123.jpg",
              "role": "admin",
              "created_at": "2024-01-15T10:30:00Z",
              "last_login": "2025-04-16T14:22:00Z",
              "preferences": {
                "theme": "dark",
                "notifications": true,
                "language": "en"
              }
            }
            """,
            contentType: .json,
            size: 412
        ),
        duration: 0.187,
        requestSize: 128,
        responseSize: 412,
        timestamp: .mockDate(minutesAgo: 5),
        completedAt: .mockDate(minutesAgo: 5).addingTimeInterval(0.187),
        status: .success,
        isFavorite: true,
        tags: [.api]
    )

    // MARK: - POST /login

    static let postLogin = NetworkRequest(
        method: .post,
        url: "https://api.example.com/v1/auth/login",
        host: "api.example.com",
        path: "/v1/auth/login",
        scheme: "https",
        statusCode: 200,
        requestHeaders: [
            RequestHeader(key: "Content-Type", value: "application/json"),
            RequestHeader(key: "User-Agent", value: "Inspectly/1.0 iOS/17.0")
        ],
        responseHeaders: standardResponseHeaders,
        requestBody: RequestBody(
            rawString: """
            {
              "email": "john@example.com",
              "password": "••••••••"
            }
            """,
            contentType: .json,
            size: 62
        ),
        responseBody: ResponseBody(
            rawString: """
            {
              "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
              "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4...",
              "expires_in": 3600,
              "user": {
                "id": 123,
                "name": "John Doe",
                "email": "john@example.com"
              }
            }
            """,
            contentType: .json,
            size: 256
        ),
        requestContentType: .json,
        duration: 0.456,
        requestSize: 62,
        responseSize: 256,
        timestamp: .mockDate(minutesAgo: 10),
        completedAt: .mockDate(minutesAgo: 10).addingTimeInterval(0.456),
        status: .success,
        isPinned: true,
        tags: [.auth]
    )

    // MARK: - POST /register

    static let postRegister = NetworkRequest(
        method: .post,
        url: "https://api.example.com/v1/auth/register",
        host: "api.example.com",
        path: "/v1/auth/register",
        scheme: "https",
        statusCode: 201,
        requestHeaders: standardRequestHeaders,
        responseHeaders: standardResponseHeaders,
        requestBody: RequestBody(
            rawString: """
            {
              "name": "Jane Doe",
              "email": "jane@example.com",
              "password": "securePassword123!",
              "confirm_password": "securePassword123!"
            }
            """,
            contentType: .json,
            size: 142
        ),
        responseBody: ResponseBody(
            rawString: """
            {
              "id": 456,
              "name": "Jane Doe",
              "email": "jane@example.com",
              "created_at": "2025-04-17T10:00:00Z"
            }
            """,
            contentType: .json,
            size: 128
        ),
        requestContentType: .json,
        duration: 0.678,
        requestSize: 142,
        responseSize: 128,
        timestamp: .mockDate(minutesAgo: 15),
        completedAt: .mockDate(minutesAgo: 15).addingTimeInterval(0.678),
        status: .success,
        tags: [.auth]
    )

    // MARK: - PUT /profile

    static let putProfile = NetworkRequest(
        method: .put,
        url: "https://api.example.com/v1/users/123/profile",
        host: "api.example.com",
        path: "/v1/users/123/profile",
        scheme: "https",
        statusCode: 200,
        requestHeaders: standardRequestHeaders,
        responseHeaders: standardResponseHeaders,
        requestBody: RequestBody(
            rawString: """
            {
              "name": "John Updated",
              "bio": "Senior iOS Developer",
              "avatar_url": "https://api.example.com/avatars/new.jpg"
            }
            """,
            contentType: .json,
            size: 142
        ),
        responseBody: ResponseBody(
            rawString: """
            {
              "id": 123,
              "name": "John Updated",
              "bio": "Senior iOS Developer",
              "updated_at": "2025-04-17T10:30:00Z"
            }
            """,
            contentType: .json,
            size: 156
        ),
        requestContentType: .json,
        duration: 0.312,
        requestSize: 142,
        responseSize: 156,
        timestamp: .mockDate(minutesAgo: 20),
        completedAt: .mockDate(minutesAgo: 20).addingTimeInterval(0.312),
        status: .success,
        tags: [.api]
    )

    // MARK: - PATCH /settings

    static let patchSettings = NetworkRequest(
        method: .patch,
        url: "https://api.example.com/v1/users/123/settings",
        host: "api.example.com",
        path: "/v1/users/123/settings",
        scheme: "https",
        statusCode: 200,
        requestHeaders: standardRequestHeaders,
        responseHeaders: standardResponseHeaders,
        requestBody: RequestBody(
            rawString: """
            {
              "notifications": false,
              "theme": "dark"
            }
            """,
            contentType: .json,
            size: 52
        ),
        responseBody: ResponseBody(
            rawString: """
            {
              "notifications": false,
              "theme": "dark",
              "updated_at": "2025-04-17T10:35:00Z"
            }
            """,
            contentType: .json,
            size: 86
        ),
        requestContentType: .json,
        duration: 0.198,
        requestSize: 52,
        responseSize: 86,
        timestamp: .mockDate(minutesAgo: 25),
        completedAt: .mockDate(minutesAgo: 25).addingTimeInterval(0.198),
        status: .success,
        tags: [.api]
    )

    // MARK: - DELETE /notifications/123

    static let deleteNotification = NetworkRequest(
        method: .delete,
        url: "https://api.example.com/v1/notifications/123",
        host: "api.example.com",
        path: "/v1/notifications/123",
        scheme: "https",
        statusCode: 204,
        requestHeaders: standardRequestHeaders,
        responseHeaders: [
            RequestHeader(key: "Date", value: "Thu, 17 Apr 2025 10:40:00 GMT"),
            RequestHeader(key: "X-Request-ID", value: "req_del_789")
        ],
        duration: 0.145,
        requestSize: 128,
        responseSize: 0,
        timestamp: .mockDate(minutesAgo: 30),
        completedAt: .mockDate(minutesAgo: 30).addingTimeInterval(0.145),
        status: .success
    )

    // MARK: - 401 Unauthorized

    static let unauthorized = NetworkRequest(
        method: .get,
        url: "https://api.example.com/v1/admin/dashboard",
        host: "api.example.com",
        path: "/v1/admin/dashboard",
        scheme: "https",
        statusCode: 401,
        requestHeaders: [
            RequestHeader(key: "Accept", value: "application/json"),
            RequestHeader(key: "Authorization", value: "Bearer expired_token_here")
        ],
        responseHeaders: standardResponseHeaders,
        responseBody: ResponseBody(
            rawString: """
            {
              "error": "unauthorized",
              "message": "Token has expired. Please refresh your token or login again.",
              "code": "AUTH_TOKEN_EXPIRED"
            }
            """,
            contentType: .json,
            size: 142
        ),
        duration: 0.089,
        requestSize: 128,
        responseSize: 142,
        timestamp: .mockDate(minutesAgo: 35),
        completedAt: .mockDate(minutesAgo: 35).addingTimeInterval(0.089),
        status: .clientError,
        errorMessage: "Token has expired"
    )

    // MARK: - 403 Forbidden

    static let forbidden = NetworkRequest(
        method: .delete,
        url: "https://api.example.com/v1/users/999",
        host: "api.example.com",
        path: "/v1/users/999",
        scheme: "https",
        statusCode: 403,
        requestHeaders: standardRequestHeaders,
        responseHeaders: standardResponseHeaders,
        responseBody: ResponseBody(
            rawString: """
            {
              "error": "forbidden",
              "message": "You do not have permission to delete this user.",
              "code": "INSUFFICIENT_PERMISSIONS"
            }
            """,
            contentType: .json,
            size: 128
        ),
        duration: 0.067,
        requestSize: 128,
        responseSize: 128,
        timestamp: .mockDate(minutesAgo: 40),
        completedAt: .mockDate(minutesAgo: 40).addingTimeInterval(0.067),
        status: .clientError,
        errorMessage: "Insufficient permissions"
    )

    // MARK: - 404 Not Found

    static let notFound = NetworkRequest(
        method: .get,
        url: "https://api.example.com/v1/products/99999",
        host: "api.example.com",
        path: "/v1/products/99999",
        scheme: "https",
        statusCode: 404,
        requestHeaders: standardRequestHeaders,
        responseHeaders: standardResponseHeaders,
        responseBody: ResponseBody(
            rawString: """
            {
              "error": "not_found",
              "message": "The requested resource could not be found.",
              "code": "RESOURCE_NOT_FOUND"
            }
            """,
            contentType: .json,
            size: 112
        ),
        duration: 0.054,
        requestSize: 128,
        responseSize: 112,
        timestamp: .mockDate(minutesAgo: 45),
        completedAt: .mockDate(minutesAgo: 45).addingTimeInterval(0.054),
        status: .clientError,
        errorMessage: "Resource not found"
    )

    // MARK: - 500 Server Error

    static let serverError = NetworkRequest(
        method: .post,
        url: "https://api.example.com/v1/orders",
        host: "api.example.com",
        path: "/v1/orders",
        scheme: "https",
        statusCode: 500,
        requestHeaders: standardRequestHeaders,
        responseHeaders: standardResponseHeaders,
        requestBody: RequestBody(
            rawString: """
            {
              "product_id": 42,
              "quantity": 1,
              "shipping_address_id": 7
            }
            """,
            contentType: .json,
            size: 86
        ),
        responseBody: ResponseBody(
            rawString: """
            {
              "error": "internal_server_error",
              "message": "An unexpected error occurred. Please try again later.",
              "code": "SERVER_ERROR",
              "trace_id": "trace_xyz789"
            }
            """,
            contentType: .json,
            size: 186
        ),
        requestContentType: .json,
        duration: 2.345,
        requestSize: 86,
        responseSize: 186,
        timestamp: .mockDate(minutesAgo: 50),
        completedAt: .mockDate(minutesAgo: 50).addingTimeInterval(2.345),
        status: .serverError,
        errorMessage: "Internal server error"
    )

    // MARK: - Timeout Request

    static let timeoutRequest = NetworkRequest(
        method: .get,
        url: "https://api.example.com/v1/reports/generate",
        host: "api.example.com",
        path: "/v1/reports/generate",
        scheme: "https",
        requestHeaders: standardRequestHeaders,
        queryParameters: [
            QueryParameter(key: "type", value: "annual"),
            QueryParameter(key: "year", value: "2024")
        ],
        duration: 30.0,
        requestSize: 128,
        timestamp: .mockDate(hoursAgo: 1),
        status: .timeout,
        errorMessage: "The request timed out after 30 seconds."
    )

    // MARK: - Slow Loading Request

    static let slowRequest = NetworkRequest(
        method: .get,
        url: "https://api.example.com/v1/analytics/dashboard",
        host: "api.example.com",
        path: "/v1/analytics/dashboard",
        scheme: "https",
        statusCode: 200,
        requestHeaders: standardRequestHeaders,
        responseHeaders: standardResponseHeaders,
        responseBody: ResponseBody(
            rawString: """
            {
              "revenue": 125000.50,
              "users": 4521,
              "conversion_rate": 3.2,
              "charts": {
                "monthly": [12000, 15000, 13500, 18000, 22000, 19500],
                "weekly": [3200, 2800, 3500, 4100, 3900, 4200, 3800]
              }
            }
            """,
            contentType: .json,
            size: 512
        ),
        duration: 4.567,
        requestSize: 128,
        responseSize: 512,
        timestamp: .mockDate(hoursAgo: 2),
        completedAt: .mockDate(hoursAgo: 2).addingTimeInterval(4.567),
        status: .success,
        isPinned: true,
        tags: [.api]
    )

    // MARK: - Multipart Upload

    static let multipartUpload = NetworkRequest(
        method: .post,
        url: "https://api.example.com/v1/uploads/avatar",
        host: "api.example.com",
        path: "/v1/uploads/avatar",
        scheme: "https",
        statusCode: 200,
        requestHeaders: [
            RequestHeader(key: "Content-Type", value: "multipart/form-data; boundary=----WebKitFormBoundary"),
            RequestHeader(key: "Authorization", value: "Bearer eyJhbGciOiJIUzI1NiIs..."),
            RequestHeader(key: "Content-Length", value: "2048576")
        ],
        responseHeaders: standardResponseHeaders,
        requestBody: RequestBody(
            rawString: "[Binary data: image/jpeg, 2.0 MB]",
            contentType: .multipartFormData,
            size: 2_048_576
        ),
        responseBody: ResponseBody(
            rawString: """
            {
              "url": "https://cdn.example.com/avatars/123_v2.jpg",
              "size": 2048576,
              "format": "jpeg",
              "dimensions": {"width": 800, "height": 800}
            }
            """,
            contentType: .json,
            size: 156
        ),
        requestContentType: .multipartFormData,
        duration: 1.234,
        requestSize: 2_048_576,
        responseSize: 156,
        timestamp: .mockDate(hoursAgo: 3),
        completedAt: .mockDate(hoursAgo: 3).addingTimeInterval(1.234),
        status: .success,
        tags: [.upload]
    )

    // MARK: - GraphQL Request

    static let graphQLRequest = NetworkRequest(
        method: .post,
        url: "https://api.example.com/graphql",
        host: "api.example.com",
        path: "/graphql",
        scheme: "https",
        statusCode: 200,
        requestHeaders: [
            RequestHeader(key: "Content-Type", value: "application/json"),
            RequestHeader(key: "Authorization", value: "Bearer eyJhbGciOiJIUzI1NiIs...")
        ],
        responseHeaders: standardResponseHeaders,
        requestBody: RequestBody(
            rawString: """
            {
              "query": "query GetUser($id: ID!) { user(id: $id) { id name email posts { id title createdAt } } }",
              "variables": {"id": "123"}
            }
            """,
            contentType: .json,
            size: 186
        ),
        responseBody: ResponseBody(
            rawString: """
            {
              "data": {
                "user": {
                  "id": "123",
                  "name": "John Doe",
                  "email": "john@example.com",
                  "posts": [
                    {"id": "1", "title": "Getting Started with SwiftUI", "createdAt": "2025-01-15"},
                    {"id": "2", "title": "Advanced Combine Patterns", "createdAt": "2025-02-20"}
                  ]
                }
              }
            }
            """,
            contentType: .json,
            size: 384
        ),
        requestContentType: .graphql,
        duration: 0.345,
        requestSize: 186,
        responseSize: 384,
        timestamp: .mockDate(hoursAgo: 4),
        completedAt: .mockDate(hoursAgo: 4).addingTimeInterval(0.345),
        status: .success,
        isFavorite: true,
        tags: [.graphQL]
    )

    // MARK: - Stubbed Login Response

    static let stubbedLogin = NetworkRequest(
        method: .post,
        url: "https://api.example.com/v1/auth/login",
        host: "api.example.com",
        path: "/v1/auth/login",
        scheme: "https",
        statusCode: 200,
        requestHeaders: [
            RequestHeader(key: "Content-Type", value: "application/json")
        ],
        responseHeaders: [
            RequestHeader(key: "Content-Type", value: "application/json"),
            RequestHeader(key: "X-Stub", value: "true")
        ],
        requestBody: RequestBody(
            rawString: """
            {"email": "test@example.com", "password": "password"}
            """,
            contentType: .json,
            size: 56
        ),
        responseBody: ResponseBody(
            rawString: """
            {
              "token": "mock_token_123456789",
              "user": {"id": 1, "name": "Test User", "email": "test@example.com"}
            }
            """,
            contentType: .json,
            size: 128
        ),
        requestContentType: .json,
        duration: 0.05,
        requestSize: 56,
        responseSize: 128,
        timestamp: .mockDate(hoursAgo: 5),
        completedAt: .mockDate(hoursAgo: 5).addingTimeInterval(0.05),
        status: .success,
        isStubbed: true,
        tags: [.auth],
        stubScenarioName: "Happy Path",
        source: .stubbed
    )

    // MARK: - Stubbed Empty Users

    static let stubbedEmptyUsers = NetworkRequest(
        method: .get,
        url: "https://api.example.com/v1/users",
        host: "api.example.com",
        path: "/v1/users",
        scheme: "https",
        statusCode: 200,
        requestHeaders: standardRequestHeaders,
        responseHeaders: [
            RequestHeader(key: "Content-Type", value: "application/json"),
            RequestHeader(key: "X-Stub", value: "true")
        ],
        responseBody: ResponseBody(
            rawString: """
            {
              "data": [],
              "meta": {"page": 1, "limit": 20, "total": 0}
            }
            """,
            contentType: .json,
            size: 64
        ),
        duration: 0.01,
        requestSize: 128,
        responseSize: 64,
        timestamp: .mockDate(hoursAgo: 6),
        completedAt: .mockDate(hoursAgo: 6).addingTimeInterval(0.01),
        status: .success,
        isStubbed: true,
        stubScenarioName: "Empty Response",
        source: .stubbed
    )

    // MARK: - Stubbed Server Failure

    static let stubbedServerFailure = NetworkRequest(
        method: .get,
        url: "https://api.example.com/v1/products",
        host: "api.example.com",
        path: "/v1/products",
        scheme: "https",
        statusCode: 500,
        requestHeaders: standardRequestHeaders,
        responseHeaders: [
            RequestHeader(key: "Content-Type", value: "application/json"),
            RequestHeader(key: "X-Stub", value: "true")
        ],
        responseBody: ResponseBody(
            rawString: """
            {
              "error": "internal_server_error",
              "message": "Simulated server failure for testing."
            }
            """,
            contentType: .json,
            size: 96
        ),
        duration: 0.5,
        requestSize: 128,
        responseSize: 96,
        timestamp: .mockDate(hoursAgo: 7),
        completedAt: .mockDate(hoursAgo: 7).addingTimeInterval(0.5),
        status: .serverError,
        isStubbed: true,
        errorMessage: "Simulated server failure",
        stubScenarioName: "Server Error",
        source: .stubbed
    )

    // MARK: - Yesterday Requests

    static let yesterdayGet = NetworkRequest(
        method: .get,
        url: "https://api.example.com/v1/feed",
        host: "api.example.com",
        path: "/v1/feed",
        scheme: "https",
        statusCode: 200,
        requestHeaders: standardRequestHeaders,
        responseHeaders: standardResponseHeaders,
        responseBody: ResponseBody(rawString: "{\"items\": []}", contentType: .json, size: 14),
        duration: 0.289,
        timestamp: .mockDate(daysAgo: 1),
        status: .success
    )

    static let yesterdayPost = NetworkRequest(
        method: .post,
        url: "https://api.example.com/v1/events/track",
        host: "api.example.com",
        path: "/v1/events/track",
        scheme: "https",
        statusCode: 202,
        requestHeaders: standardRequestHeaders,
        responseHeaders: standardResponseHeaders,
        requestBody: RequestBody(rawString: "{\"event\": \"page_view\", \"page\": \"/home\"}", contentType: .json, size: 42),
        duration: 0.156,
        timestamp: .mockDate(daysAgo: 1),
        status: .success
    )

    // MARK: - All Mock Requests

    static let all: [NetworkRequest] = [
        getUsersList,
        getUserDetail,
        postLogin,
        postRegister,
        putProfile,
        patchSettings,
        deleteNotification,
        unauthorized,
        forbidden,
        notFound,
        serverError,
        timeoutRequest,
        slowRequest,
        multipartUpload,
        graphQLRequest,
        stubbedLogin,
        stubbedEmptyUsers,
        stubbedServerFailure,
        yesterdayGet,
        yesterdayPost
    ]
}

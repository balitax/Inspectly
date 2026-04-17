//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation

// MARK: - Mock Stubs

public struct MockStubs {

    // MARK: - Login Stub

    static let loginStub = RequestStub(
        name: "Login - Happy Path",
        description: "Returns a successful login response with mock token.",
        matchRule: StubMatchRule(
            method: .post,
            urlPath: "/v1/auth/login"
        ),
        scenarios: [
            StubScenario(
                name: "Success",
                description: "Returns valid token and user data.",
                response: StubResponse(
                    statusCode: 200,
                    jsonBody: """
                    {
                      "token": "mock_jwt_token_abc123",
                      "refresh_token": "mock_refresh_token_xyz",
                      "expires_in": 3600,
                      "user": {
                        "id": 1,
                        "name": "Test User",
                        "email": "test@example.com"
                      }
                    }
                    """,
                    responseDelay: 0.3
                ),
                isActive: true
            ),
            StubScenario(
                name: "Invalid Credentials",
                description: "Returns 401 for wrong password.",
                response: StubResponse(
                    statusCode: 401,
                    jsonBody: """
                    {
                      "error": "invalid_credentials",
                      "message": "The email or password you entered is incorrect."
                    }
                    """,
                    responseDelay: 0.5
                )
            ),
            StubScenario(
                name: "Account Locked",
                description: "Returns 423 when account is locked.",
                response: StubResponse(
                    statusCode: 423,
                    jsonBody: """
                    {
                      "error": "account_locked",
                      "message": "Your account has been locked due to too many failed attempts."
                    }
                    """,
                    responseDelay: 0.2
                )
            )
        ],
        isEnabled: true,
        usageCount: 47,
        lastTriggered: .mockDate(minutesAgo: 5),
        groupName: "Authentication"
    )

    // MARK: - Users List Stub

    static let usersListStub = RequestStub(
        name: "Users List",
        description: "Returns a paginated list of users.",
        matchRule: StubMatchRule(
            method: .get,
            urlPath: "/v1/users"
        ),
        scenarios: [
            StubScenario(
                name: "With Data",
                description: "Returns a list of 3 users.",
                response: StubResponse(
                    statusCode: 200,
                    jsonBody: """
                    {
                      "data": [
                        {"id": 1, "name": "Alice", "email": "alice@example.com"},
                        {"id": 2, "name": "Bob", "email": "bob@example.com"},
                        {"id": 3, "name": "Carol", "email": "carol@example.com"}
                      ],
                      "meta": {"page": 1, "total": 3}
                    }
                    """,
                    responseDelay: 0.2
                ),
                isActive: true
            ),
            StubScenario(
                name: "Empty List",
                description: "Returns an empty users list.",
                response: StubResponse(
                    statusCode: 200,
                    jsonBody: """
                    {
                      "data": [],
                      "meta": {"page": 1, "total": 0}
                    }
                    """,
                    responseDelay: 0.1
                )
            ),
            StubScenario(
                name: "Server Error",
                description: "Simulates a 500 error.",
                response: StubResponse(
                    statusCode: 500,
                    jsonBody: """
                    {
                      "error": "internal_server_error",
                      "message": "Something went wrong."
                    }
                    """,
                    responseDelay: 1.0,
                    errorType: .internalServerError
                )
            )
        ],
        isEnabled: true,
        usageCount: 23,
        lastTriggered: .mockDate(minutesAgo: 12),
        groupName: "Users"
    )

    // MARK: - Profile Update Stub

    static let profileUpdateStub = RequestStub(
        name: "Update Profile",
        description: "Stub for profile update endpoint.",
        matchRule: StubMatchRule(
            method: .put,
            urlPath: "/v1/users/123/profile"
        ),
        scenarios: [
            StubScenario(
                name: "Success",
                description: "Profile updated successfully.",
                response: StubResponse(
                    statusCode: 200,
                    jsonBody: """
                    {
                      "id": 123,
                      "name": "Updated Name",
                      "bio": "Updated bio",
                      "updated_at": "2025-04-17T12:00:00Z"
                    }
                    """,
                    responseDelay: 0.4
                ),
                isActive: true
            ),
            StubScenario(
                name: "Validation Error",
                description: "Returns validation errors.",
                response: StubResponse(
                    statusCode: 422,
                    jsonBody: """
                    {
                      "error": "validation_error",
                      "errors": [
                        {"field": "name", "message": "Name is required"},
                        {"field": "bio", "message": "Bio must be less than 500 characters"}
                      ]
                    }
                    """
                )
            )
        ],
        isEnabled: false,
        usageCount: 8,
        lastTriggered: .mockDate(hoursAgo: 2),
        groupName: "Users"
    )

    // MARK: - Network Error Stub

    static let networkErrorStub = RequestStub(
        name: "Simulate Timeout",
        description: "Simulates a network timeout for testing error handling.",
        matchRule: StubMatchRule(
            method: .get,
            urlPath: "/v1/reports"
        ),
        scenarios: [
            StubScenario(
                name: "Timeout",
                description: "30 second timeout simulation.",
                response: StubResponse(
                    statusCode: 0,
                    responseDelay: 30.0,
                    errorType: .timeout
                ),
                isActive: true
            ),
            StubScenario(
                name: "No Internet",
                description: "Simulates no internet connection.",
                response: StubResponse(
                    statusCode: 0,
                    errorType: .noInternet
                )
            )
        ],
        isEnabled: true,
        usageCount: 5,
        lastTriggered: .mockDate(hoursAgo: 6),
        groupName: "Error Simulation"
    )

    // MARK: - Orders Stub

    static let ordersStub = RequestStub(
        name: "Create Order",
        description: "Stub for order creation endpoint.",
        matchRule: StubMatchRule(
            method: .post,
            urlPath: "/v1/orders"
        ),
        scenarios: [
            StubScenario(
                name: "Success",
                description: "Order created successfully.",
                response: StubResponse(
                    statusCode: 201,
                    jsonBody: """
                    {
                      "id": "ORD-12345",
                      "status": "pending",
                      "total": 99.99,
                      "created_at": "2025-04-17T12:00:00Z"
                    }
                    """,
                    responseDelay: 0.8
                ),
                isActive: true
            )
        ],
        isEnabled: true,
        usageCount: 12,
        lastTriggered: .mockDate(hoursAgo: 1),
        groupName: "Orders"
    )

    // MARK: - All Stubs

    public static let all: [RequestStub] = [
        loginStub,
        usersListStub,
        profileUpdateStub,
        networkErrorStub,
        ordersStub
    ]
}

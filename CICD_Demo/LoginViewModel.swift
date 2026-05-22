//
//  LoginViewModel.swift
//  CICD_Demo
//

import Foundation

struct LoginResponse: Codable, Equatable {
    let token: String
    let displayName: String
}

enum LoginError: Error, Equatable {
    case invalidCredentials
    case network(String)
}

protocol LoginServicing {
    func login(username: String, password: String) async throws -> LoginResponse
}

/// Demo：模拟 REST 登录。正式项目可换成 URLSession + Codable。
nonisolated final class LoginService: LoginServicing, @unchecked Sendable {
    func login(username: String, password: String) async throws -> LoginResponse {
        try await Task.sleep(nanoseconds: 200_000_000)
        guard username == "demo", password == "pass123" else {
            throw LoginError.invalidCredentials
        }
        return LoginResponse(token: "mock-jwt-token", displayName: "Demo User")
    }
}

@MainActor
final class LoginViewModel {
    private(set) var displayName: String?
    private(set) var errorMessage: String?
    private(set) var isLoading = false

    private let service: LoginServicing

    init(service: LoginServicing) {
        self.service = service
    }

    convenience init() {
        self.init(service: LoginService())
    }

    func login(username: String, password: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await service.login(username: username, password: password)
            displayName = response.displayName
        } catch LoginError.invalidCredentials {
            errorMessage = "Invalid username or password"
        } catch {
            errorMessage = "Network error"
        }
    }
}

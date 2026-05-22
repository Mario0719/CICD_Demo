//
//  LoginViewModelTests.swift
//  CICD_DemoTests
//

import XCTest
@testable import CICD_Demo

nonisolated final class MockLoginService: LoginServicing, @unchecked Sendable {
    var stub: Result<LoginResponse, Error> = .success(
        LoginResponse(token: "t", displayName: "Mock")
    )

    func login(username: String, password: String) async throws -> LoginResponse {
        try stub.get()
    }
}

@MainActor
final class LoginViewModelTests: XCTestCase {
    func testLoginSuccess() async {
        let mock = MockLoginService()
        mock.stub = .success(LoginResponse(token: "jwt", displayName: "Alice"))
        let vm = LoginViewModel(service: mock)

        await vm.login(username: "demo", password: "pass123")

        XCTAssertEqual(vm.displayName, "Alice")
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.isLoading)
    }

    func testLoginInvalidCredentials() async {
        let mock = MockLoginService()
        mock.stub = .failure(LoginError.invalidCredentials)
        let vm = LoginViewModel(service: mock)

        await vm.login(username: "wrong", password: "wrong")

        XCTAssertNil(vm.displayName)
        XCTAssertEqual(vm.errorMessage, "Invalid username or password")
    }
}

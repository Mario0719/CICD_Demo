//
//  JSONParsingTests.swift
//  CICD_DemoTests
//

import XCTest
@testable import CICD_Demo

final class JSONParsingTests: XCTestCase {
    func testDecodeLoginResponse() throws {
        let json = """
        {"token":"abc","displayName":"Bob"}
        """
        let data = Data(json.utf8)
        let response = try JSONDecoder().decode(LoginResponse.self, from: data)
        XCTAssertEqual(response.token, "abc2")
        XCTAssertEqual(response.displayName, "Bob")
    }
}

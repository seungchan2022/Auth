import XCTest
@testable import Authentication

final class AuthenticationTests: XCTestCase {
  func testExample() throws {
    XCTAssertEqual(echo(), "Hello, World!!")
  }

  func echo() -> String {
    "Hello, World!!"
  }
}

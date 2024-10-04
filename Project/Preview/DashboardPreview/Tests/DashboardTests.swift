import XCTest
@testable import Dashboard

final class DashboardTests: XCTestCase {
  func testExample() throws {
    XCTAssertEqual(echo(), "Hello, World!!")
  }

  func echo() -> String {
    "Hello, World!!"
  }
}

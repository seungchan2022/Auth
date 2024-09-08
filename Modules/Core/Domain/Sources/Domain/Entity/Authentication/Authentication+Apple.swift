import Foundation

// MARK: - Authentication.Apple

extension Authentication {
  public enum Apple { }
}

// MARK: - Authentication.Apple.Request

extension Authentication.Apple {
  public struct Request: Equatable, Codable, Sendable {
    public let nonce: String

    public init(nonce: String) {
      self.nonce = nonce
    }
  }
}

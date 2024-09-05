import Foundation

// MARK: - Authentication.Email

extension Authentication {
  public enum Email { }
}

// MARK: - Authentication.Email.Request

extension Authentication.Email {
  public struct Request: Equatable, Codable, Sendable {
    public let email: String
    public let password: String

    public init(
      email: String,
      password: String)
    {
      self.email = email
      self.password = password
    }
  }
}

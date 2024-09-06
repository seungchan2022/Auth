import Foundation

// MARK: - Authentication.Me

extension Authentication {
  public enum Me { }
}

// MARK: - Authentication.Me.Response

extension Authentication.Me {
  public struct Response: Equatable, Codable, Sendable {
    public let uid: String
    public let userName: String?
    public let email: String?
    public let photoURL: String?

    public init(
      uid: String,
      userName: String?,
      email: String?,
      photoURL: String?)
    {
      self.uid = uid
      self.userName = userName
      self.email = email
      self.photoURL = photoURL
    }
  }
}

import Foundation

// MARK: - Link.Authentication

extension Link {
  public enum Authentication { }
}

// MARK: - Link.Authentication.Path

extension Link.Authentication {
  public enum Path: String, Equatable {
    case landing
    case me
    case signIn
    case signUp
    case updateAuth
    case updatePassword
  }
}

import Firebase
import Foundation
import GoogleSignIn

// MARK: - ThirdPartyContainer

public class ThirdPartyContainer {

  public init() { }
}

extension ThirdPartyContainer {
  public func connect() {
    FirebaseApp.configure()
  }

  public func perform(url: URL) -> Bool {
    GIDSignIn.sharedInstance.handle(url)
  }
}

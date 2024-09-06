import Combine
import Foundation

public protocol AuthenticationUseCase {
  var signUpEmail: (Authentication.Email.Request) -> AnyPublisher<Void, CompositeErrorRepository> { get }

  var signInEmail: (Authentication.Email.Request) -> AnyPublisher<Void, CompositeErrorRepository> { get }

  var me: () -> AnyPublisher<Authentication.Me.Response?, CompositeErrorRepository> { get }

  var signOut: () -> AnyPublisher<Void, CompositeErrorRepository> { get }

  var updateUserName: (String) -> AnyPublisher<Void, CompositeErrorRepository> { get }

}

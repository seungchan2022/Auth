import Combine
import Foundation

public protocol AuthenticationUseCase {
  var signUpEmail: (Authentication.Email.Request) -> AnyPublisher<Void, CompositeErrorRepository> { get }

  var signInEmail: (Authentication.Email.Request) -> AnyPublisher<Void, CompositeErrorRepository> { get }
}

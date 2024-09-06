import Combine
import Domain
import Firebase
import FirebaseAuth

// MARK: - AuthenticationUseCasePlatform

public struct AuthenticationUseCasePlatform {
  public init() { }
}

// MARK: AuthenticationUseCase

extension AuthenticationUseCasePlatform: AuthenticationUseCase {
  public var signUpEmail: (Authentication.Email.Request) -> AnyPublisher<Void, CompositeErrorRepository> {
    { req in
      Future<Void, CompositeErrorRepository> { promise in
        Auth.auth().createUser(withEmail: req.email, password: req.password) { _, error in
          guard let error else { return promise(.success(Void())) }

          return promise(.failure(.other(error)))
        }
      }
      .eraseToAnyPublisher()
    }
  }

  public var signInEmail: (Authentication.Email.Request) -> AnyPublisher<Void, CompositeErrorRepository> {
    { req in
      Future<Void, CompositeErrorRepository> { promise in
        Auth.auth().signIn(withEmail: req.email, password: req.password) { _, error in
          guard let error else { return promise(.success(Void())) }

          return promise(.failure(.other(error)))
        }
      }
      .eraseToAnyPublisher()
    }
  }

  public var me: () -> AnyPublisher<Authentication.Me.Response?, CompositeErrorRepository> {
    {
      Future<Authentication.Me.Response?, CompositeErrorRepository> { promise in
        guard let me = Auth.auth().currentUser else { return promise(.success(.none)) }

        return promise(.success(me.serialized()))
      }
      .eraseToAnyPublisher()
    }
  }

  public var signOut: () -> AnyPublisher<Void, CompositeErrorRepository> {
    {
      Future<Void, CompositeErrorRepository> { promise in
        do {
          try Auth.auth().signOut()
          return promise(.success(Void()))
        } catch {
          return promise(.failure(.other(error)))
        }
      }
      .eraseToAnyPublisher()
    }
  }

  public var updateUserName: (String) -> AnyPublisher<Void, CompositeErrorRepository> {
    { newName in
      Future<Void, CompositeErrorRepository> { promise in
        guard let me = Auth.auth().currentUser else { return promise(.success(Void())) }

        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = newName
        changeRequest?.commitChanges { error in
          guard let error else {
            return promise(.success(Void()))
          }

          return promise(.failure(.other(error)))
        }
      }
      .eraseToAnyPublisher()
    }
  }

  public var updatePassword: (String, String) -> AnyPublisher<Void, CompositeErrorRepository> {
    { currPassword, newPassword in
      Future<Void, CompositeErrorRepository> { promise in

        guard let me = Auth.auth().currentUser else { return promise(.success(Void())) }

        let credential = EmailAuthProvider.credential(withEmail: me.email ?? "", password: currPassword)

        me.reauthenticate(with: credential) { _, error in
          if error != nil {
            return promise(.failure(.currPasswordError))
          } else {
            me.updatePassword(to: newPassword) { error in
              guard let error else { return promise(.success(Void())) }
              return promise(.failure(.other(error)))
            }
          }
        }
      }
      .eraseToAnyPublisher()
    }
  }

  public var deleteUser: (String) -> AnyPublisher<Void, CompositeErrorRepository> {
    { currPassword in
      Future<Void, CompositeErrorRepository> { promise in
        guard let me = Auth.auth().currentUser else { return promise(.success(Void())) }

        let credential = EmailAuthProvider.credential(withEmail: me.email ?? "", password: currPassword)

        me.reauthenticate(with: credential) { _, error in
          if error != nil {
            return promise(.failure(.currPasswordError))
          } else {
            me.delete { error in
              guard let error else { return promise(.success(Void())) }

              return promise(.failure(.other(error)))
            }
          }
        }
      }
      .eraseToAnyPublisher()
    }
  }
}

extension User {
  fileprivate func serialized() -> Authentication.Me.Response {
    .init(
      uid: uid,
      userName: displayName,
      email: email,
      photoURL: photoURL?.absoluteString)
  }
}

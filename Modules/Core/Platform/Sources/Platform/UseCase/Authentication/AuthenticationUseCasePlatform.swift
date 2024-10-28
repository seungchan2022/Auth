import AuthenticationServices
import Combine
import Domain
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import GoogleSignIn

// MARK: - AuthenticationUseCasePlatform

public struct AuthenticationUseCasePlatform {
  public init() { }
}

// MARK: AuthenticationUseCase

extension AuthenticationUseCasePlatform: AuthenticationUseCase {
  public var signUpEmail: (Authentication.Email.Request) -> AnyPublisher<Void, CompositeErrorRepository> {
    { req in
      Future<Void, CompositeErrorRepository> { promise in
        Auth.auth().createUser(withEmail: req.email, password: req.password) { result, error in
          guard let error else {
            Task {
              do {
                if let user = result?.user {
                  try await uploadUserData(
                    id: user.uid,
                    email: req.email,
                    userName: req.email.components(separatedBy: "@").first ?? "")
                }
              } catch {
                return promise(.failure(.other(error)))
              }
            }

            return promise(.success(Void()))
          }

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

  public var signInApple: (Authentication.Apple.Request) -> AnyPublisher<Void, CompositeErrorRepository> {
    { _ in
      Future<Void, CompositeErrorRepository> { _ in
      }
      .eraseToAnyPublisher()
    }
  }

  public var signInGoogle: () -> AnyPublisher<Void, CompositeErrorRepository> {
    {
      Future<Void, CompositeErrorRepository> { promise in
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let rootViewController = UIApplication.shared.firstKeyWindow?.rootViewController else { return }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in

          if let error = error {
            return promise(.failure(.other(error)))
          }

          guard
            let user = result?.user,
            let idToken = user.idToken?.tokenString
          else { return }

          let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: user.accessToken.tokenString)

          Auth.auth().signIn(with: credential) { result, error in
            guard let error else {
              Task {
                do {
                  if let user = result?.user {
                    try await uploadUserData(
                      id: user.uid,
                      email: user.email ?? "",
                      userName: user.displayName ?? "")
                  }
                } catch {
                  return promise(.failure(.other(error)))
                }
              }
              return promise(.success(Void()))
            }
            return promise(.failure(.other(error)))
          }
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
            Firestore.firestore().collection("users")
              .document(me.uid)
              .updateData(["userName": newName]) { error in
                if let error = error {
                  return promise(.failure(.other(error)))
                } else {
                  return promise(.success(Void()))
                }
              }

            return promise(.success(Void()))
          }

          return promise(.failure(.other(error)))
        }
      }
      .eraseToAnyPublisher()
    }
  }

  public var updateProfileImage: (Data) -> AnyPublisher<Void, CompositeErrorRepository> {
    { imageData in
      Future<Void, CompositeErrorRepository> { promise in
        guard let me = Auth.auth().currentUser else { return }

        // 프로필 이미지를 넣을 Storage 참조 생성
        let storageRef = Storage.storage().reference()
        let profileImageRef = storageRef.child("profile_images/\(me.uid).jpg")

        // 이미지 업로드
        profileImageRef.putData(imageData, metadata: .none) { _, error in
          if let error = error {
            return promise(.failure(.other(error)))
          }

          // 업로드된 이미지 가져오기
          profileImageRef.downloadURL { url, error in
            if let error = error {
              return promise(.failure(.other(error)))
            }

            // 이미지 업로드하는 해당 이미지의 url을 가져옴
            guard let url = url else {
              return promise(.failure(.invalidTypeCasting))
            }

            // store에서 user에 대해서 정보를 저장하기 위해 이미지 url에 대한 string을 가져옴
            let photoURLString = url.absoluteString

            Firestore.firestore()
              .collection("users")
              .document(me.uid)
              .setData(["photoURL": photoURLString], merge: true) { error in
                if let error = error {
                  return promise(.failure(.other(error)))
                }

                let changeRequest = me.createProfileChangeRequest()
                changeRequest.photoURL = url

                changeRequest.commitChanges { error in
                  if let error = error {
                    return promise(.failure(.other(error)))
                  }

                  return promise(.success(Void()))
                }
              }
          }
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

  public var resetPassword: (String) -> AnyPublisher<Void, CompositeErrorRepository> {
    { email in
      Future<Void, CompositeErrorRepository> { promise in
        Auth.auth().languageCode = "ko"

        Auth.auth().sendPasswordReset(withEmail: email) { error in
          guard let error else { return promise(.success(Void())) }

          return promise(.failure(.other(error)))
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

  public var deleteUserInfo: () -> AnyPublisher<Void, CompositeErrorRepository> {
    {
      Future<Void, CompositeErrorRepository> { promise in
        guard let me = Auth.auth().currentUser else { return }

        let userRef = Firestore.firestore()
          .collection("users")
          .document(me.uid)

        Task {
          do {
            try await userRef.delete()
            return promise(.success(Void()))
          } catch {
            return promise(.failure(.other(error)))
          }
        }
      }
      .eraseToAnyPublisher()
    }
  }

  public var deleteUserProfileImage: () -> AnyPublisher<Void, CompositeErrorRepository> {
    {
      Future<Void, CompositeErrorRepository> { promise in
        guard let me = Auth.auth().currentUser else {
          return promise(.failure(.invalidTypeCasting))
        }

        let storageRef = Storage.storage().reference()

        let profileImageRef = storageRef.child("profile_images/\(me.uid).jpg")

        let userRef = Firestore.firestore()
          .collection("users")
          .document(me.uid)

        Task {
          do {
            try await profileImageRef.delete()
            try await userRef.updateData(["photoURL": ""])

            let changeRequest = me.createProfileChangeRequest()
            changeRequest.photoURL = nil

            try await changeRequest.commitChanges()

            return promise(.success(Void()))
          } catch StorageError.objectNotFound {
            return promise(.success(Void()))

          } catch {
            return promise(.failure(.other(error)))
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

extension AuthenticationUseCasePlatform {
  private func uploadUserData(id: String, email: String, userName: String) async throws {
    let user = Authentication.Me.Response(uid: id, userName: userName, email: email, photoURL: .none)
    guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
    try await Firestore.firestore().collection("users").document(id).setData(encodedUser)
  }
}

extension UIApplication {
  fileprivate var firstKeyWindow: UIWindow? {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .filter { $0.activationState == .foregroundActive }
      .first?.windows
      .first(where: \.isKeyWindow)
  }
}

import Combine
import Domain
import Firebase
import FirebaseAuth
import FirebaseFirestore

// MARK: - ChatUseCasePlatform

public struct ChatUseCasePlatform {
  public init() { }
}

// MARK: ChatUseCase

extension ChatUseCasePlatform: ChatUseCase {
  public var getUser: (String) -> AnyPublisher<Authentication.Me.Response, CompositeErrorRepository> {
    { userId in
      Future<Authentication.Me.Response, CompositeErrorRepository> { promise in
        Firestore.firestore()
          .collection("users")
          .document(userId)
          .getDocument { documentSnapshot, error in
            if let error = error {
              return promise(.failure(.other(error)))
            }
            guard
              let document = documentSnapshot,
              let user = try? document.data(as: Authentication.Me.Response.self)
            else {
              return promise(.failure(.invalidTypeCasting))
            }

            // 성공적으로 유저를 가져온 경우
            promise(.success(user))
          }
      }
      .eraseToAnyPublisher()
    }
  }

  public var userItemList: () -> AnyPublisher<[Authentication.Me.Response], CompositeErrorRepository> {
    {
      Future<[Authentication.Me.Response], CompositeErrorRepository> { promise in
        guard let me = Auth.auth().currentUser else { return }

        Firestore.firestore().collection("users")
          .getDocuments { snapshot, error in
            if let error = error {
              return promise(.failure(.other(error)))
            }

            guard let documents = snapshot?.documents else {
              return promise(.success([]))
            }

            // 문서들을 Authentication.Me.Response로 변환
            let itemList: [Authentication.Me.Response] = documents.compactMap { document in
              try? document.data(as: Authentication.Me.Response.self)
            }

            // 현재로그인한 유저는 제왜
            let filteredItemList = itemList.filter { $0.uid != me.uid }

//            return promise(.success(itemList))
            return promise(.success(filteredItemList))
          }
      }
      .eraseToAnyPublisher()
    }
  }

  public var sendMessage: (String, String) -> AnyPublisher<Chat.Message.Item, CompositeErrorRepository> {
    { toId, messageText in
      Future<Chat.Message.Item, CompositeErrorRepository> { promise in
        guard let me = Auth.auth().currentUser else { return }

        // 보내는 사람 참조
        let currentUserRef = Firestore.firestore()
          .collection("messages")
          .document(me.uid)
          .collection(toId)
          .document()

        // 받는 사람 참조
        let chatPartnerRef = Firestore.firestore()
          .collection("messages")
          .document(toId)
          .collection(me.uid)

        let messageId = currentUserRef.documentID

        let message = Chat.Message.Item(
          fromId: me.uid,
          toId: toId,
          messageText: messageText)

        guard var messageData = try? Firestore.Encoder().encode(message) else { return }
        messageData["timestamp"] = Timestamp()

        currentUserRef.setData(messageData) { error in
          if let error = error {
            return promise(.failure(.other(error)))
          }

          chatPartnerRef.document(messageId).setData(messageData) { error in
            if let error = error {
              return promise(.failure(.other(error)))
            }

            promise(.success(message))
          }
        }
      }
      .eraseToAnyPublisher()
    }
  }
}

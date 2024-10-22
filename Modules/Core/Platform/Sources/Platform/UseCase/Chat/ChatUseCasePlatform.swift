import Combine
import CombineExt
import Domain
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Foundation

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

            // 현재로그인한 유저는 제외
            let filteredItemList = itemList.filter { $0.uid != me.uid }

            return promise(.success(filteredItemList))
          }
      }
      .eraseToAnyPublisher()
    }
  }

  public var sendMessage: (String, String) -> AnyPublisher<Chat.Message.Item, CompositeErrorRepository> {
    { chatPartnerId, messageText in
      Future<Chat.Message.Item, CompositeErrorRepository> { promise in
        guard let me = Auth.auth().currentUser else { return }

        // 보내는 사람 참조
        let currentUserRef = Firestore.firestore()
          .collection("messages")
          .document(me.uid)
          .collection(chatPartnerId)
          .document()

        // 받는 사람 참조
        let chatPartnerRef = Firestore.firestore()
          .collection("messages")
          .document(chatPartnerId)
          .collection(me.uid)

        let recentUserRef = Firestore.firestore()
          .collection("messages")
          .document(me.uid)
          .collection("recentMessages")
          .document(chatPartnerId)

        let recentPartnerRef = Firestore.firestore()
          .collection("messages")
          .document(chatPartnerId)
          .collection("recentMessages")
          .document(me.uid)

        let messageId = currentUserRef.documentID

        let message = Chat.Message.Item(
          id: messageId,
          fromId: me.uid,
          toId: chatPartnerId,
          messageText: messageText,
          date: Date())

        guard let messageData = try? Firestore.Encoder().encode(message) else { return }

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

        recentUserRef.setData(messageData)
        recentPartnerRef.setData(messageData)
      }
      .eraseToAnyPublisher()
    }
  }

  public var sendImageMessage: (String, Data) -> AnyPublisher<Chat.Message.Item, CompositeErrorRepository> {
    { chatPartnerId, imageData in
      Future<Chat.Message.Item, CompositeErrorRepository> { promise in
        guard let me = Auth.auth().currentUser else { return }

        // 이미지를 넣을 Storage 참조 생성
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("images/\(me.uid).jpg")

        imageRef.putData(imageData, metadata: .none) { _, error in
          if let error = error {
            return promise(.failure(.other(error)))
          }

          imageRef.downloadURL { url, error in
            if let error = error {
              return promise(.failure(.other(error)))
            }

            guard let url = url else {
              return promise(.failure(.invalidTypeCasting))
            }

            let imageURLString = url.absoluteString

            // 이 위에는 이미지를 Storage에 추가하고, 이미지에 대한 string값을 받아옴
            // 아래에서는 snedMessage관련해서 message아이템에 대해서 세팅

            // 보내는 사람 참조
            let currentUserRef = Firestore.firestore()
              .collection("messages")
              .document(me.uid)
              .collection(chatPartnerId)
              .document()

            // 받는 사람 참조
            let chatPartnerRef = Firestore.firestore()
              .collection("messages")
              .document(chatPartnerId)
              .collection(me.uid)

            let recentUserRef = Firestore.firestore()
              .collection("messages")
              .document(me.uid)
              .collection("recentMessages")
              .document(chatPartnerId)

            let recentPartnerRef = Firestore.firestore()
              .collection("messages")
              .document(chatPartnerId)
              .collection("recentMessages")
              .document(me.uid)

            let messageId = currentUserRef.documentID

            let message = Chat.Message.Item(
              id: messageId,
              fromId: me.uid,
              toId: chatPartnerId,
              messageText: imageURLString,
              date: Date())

            guard let messageData = try? Firestore.Encoder().encode(message) else { return }

            currentUserRef.setData(messageData) { error in
              if let error = error {
                return promise(.failure(.other(error)))
              }

              chatPartnerRef.document(messageId).setData(messageData) { error in
                if let error = error {
                  return promise(.failure(.other(error)))
                }

                return promise(.success(message))
              }
            }

            recentUserRef.setData(messageData)
            recentPartnerRef.setData(messageData)
          }
        }
      }
      .eraseToAnyPublisher()
    }
  }

  public var getMessage: (Authentication.Me.Response) -> AnyPublisher<[Chat.Message.Item], CompositeErrorRepository> {
    { chatPartner in
      let messageSubject = PassthroughSubject<[Chat.Message.Item], CompositeErrorRepository>()

      guard let me = Auth.auth().currentUser else {
        return Fail(error: CompositeErrorRepository.incorrectUser).eraseToAnyPublisher()
      }

      let query = Firestore.firestore()
        .collection("messages")
        .document(me.uid)
        .collection(chatPartner.uid)
        .order(by: "date", descending: false)

      query.addSnapshotListener { snapshot, error in
        if let error = error {
          // 에러가 발생할 경우 Subject를 통해 에러 방출
          messageSubject.send(completion: .failure(.other(error)))
          return
        }

        let changes = snapshot?.documentChanges.filter { $0.type == .added } ?? []

        let messageItemList = changes.compactMap { try? $0.document.data(as: Chat.Message.Item.self) }

        // 새로운 메시지를 Subject로 전달
        messageSubject.send(messageItemList)
      }

      // Subject를 Publisher로 변환하여 반환
      return messageSubject.eraseToAnyPublisher()
    }
  }

  public var getRecentMessageList: () -> AnyPublisher<[Chat.Message.Item], CompositeErrorRepository> {
    {
      let messageSubject = PassthroughSubject<[Chat.Message.Item], CompositeErrorRepository>()

      guard let me = Auth.auth().currentUser else {
        return Fail(error: CompositeErrorRepository.incorrectUser).eraseToAnyPublisher()
      }

      let query = Firestore.firestore()
        .collection("messages")
        .document(me.uid)
        .collection("recentMessages")
        .order(by: "date", descending: true)

      query.addSnapshotListener { snapshot, error in
        if let error = error {
          messageSubject.send(completion: .failure(.other(error)))
          return
        }

        let changes = snapshot?.documentChanges.filter { $0.type == .added || $0.type == .modified } ?? []

        let newMessages = changes.compactMap { try? $0.document.data(as: Chat.Message.Item.self) }

        // 새로운 메시지 전달
        messageSubject.send(newMessages)
      }

      return messageSubject.eraseToAnyPublisher()
    }
  }

  public var deleteMessage: (String) -> AnyPublisher<String, CompositeErrorRepository> {
    { chatPartnerId in
      Future<String, CompositeErrorRepository> { promise in
        guard let me = Auth.auth().currentUser else { return }

        let recentMessageRef = Firestore.firestore()
          .collection("messages")
          .document(me.uid)
          .collection("recentMessages")
          .document(chatPartnerId)

        let chatPartnerRef = Firestore.firestore()
          .collection("messages")
          .document(me.uid)
          .collection(chatPartnerId)

        Task {
          do {
            // 최근 메시지 삭제
            try await recentMessageRef.delete()

            // 컬렉션의 모든 문서를 순차적으로 삭제
            let snapshot = try await chatPartnerRef.getDocuments()
            for document in snapshot.documents {
              try await document.reference.delete()
            }
            return promise(.success(chatPartnerId))
          } catch {
            return promise(.failure(.other(error)))
          }
        }
      }
      .eraseToAnyPublisher()
    }
  }
}

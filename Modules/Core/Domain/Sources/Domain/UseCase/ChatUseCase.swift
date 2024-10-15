import Combine
import Foundation

public protocol ChatUseCase {
  var getUser: (String) -> AnyPublisher<Authentication.Me.Response, CompositeErrorRepository> { get }

  var userItemList: () -> AnyPublisher<[Authentication.Me.Response], CompositeErrorRepository> { get }

  var sendMessage: (String, String) -> AnyPublisher<Chat.Message.Item, CompositeErrorRepository> { get }

  var getMessage: (Authentication.Me.Response) -> AnyPublisher<[Chat.Message.Item], CompositeErrorRepository> { get }

  var getRecentMessageList: () -> AnyPublisher<[Chat.Message.Item], CompositeErrorRepository> { get }
}

import Combine
import Foundation

public protocol ChatUseCase {
  var userItemList: () -> AnyPublisher<[Authentication.Me.Response], CompositeErrorRepository> { get }
}

import Foundation

// MARK: - ToastViewActionMock

public class ToastViewActionMock {

  // MARK: Lifecycle

  public init(event: Event = .init()) {
    self.event = event
  }

  // MARK: Public

  public var event: Event = .init()

}

// MARK: ToastViewActionMock.Event

extension ToastViewActionMock {
  public struct Event: Equatable, Sendable {
    public var sendMessage: Int = .zero
    public var sendErrorMessage: Int = .zero
    public var clear: Int = .zero

    public init(
      sendMessage: Int = .zero,
      sendErrorMessage: Int = .zero,
      clear: Int = .zero)
    {
      self.sendMessage = sendMessage
      self.sendErrorMessage = sendErrorMessage
      self.clear = clear
    }
  }
}

// MARK: ToastViewActionType

extension ToastViewActionMock: ToastViewActionType {
  public func send(message _: String) {
    event.sendMessage += 1
  }

  public func send(errorMessage _: String) {
    event.sendErrorMessage += 1
  }

  public func clear() {
    event.clear += 1
  }
}

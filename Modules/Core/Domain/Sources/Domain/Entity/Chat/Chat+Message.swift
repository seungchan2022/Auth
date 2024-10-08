import Foundation

// MARK: - Chat.Message

extension Chat {
  public enum Message { }
}

// MARK: - Chat.Message.Item

extension Chat.Message {
  public struct Item: Equatable, Codable, Sendable {
    public let fromId: String // 보내는 사람 id
    public let toId: String // 받는 사람 id
    public let messageText: String

    public init(
      fromId: String,
      toId: String,
      messageText: String)
    {
      self.fromId = fromId
      self.toId = toId
      self.messageText = messageText
    }
  }
}

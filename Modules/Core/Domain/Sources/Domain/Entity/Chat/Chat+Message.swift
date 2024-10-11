import Foundation

// MARK: - Chat.Message

extension Chat {
  public enum Message { }
}

// MARK: - Chat.Message.Item

extension Chat.Message {
  public struct Item: Equatable, Codable, Sendable, Identifiable {
    public let id: String
    public let fromId: String // 보내는 사람 id
    public let toId: String // 받는 사람 id
    public let messageText: String
    public let date: Date

    public init(
      id: String,
      fromId: String,
      toId: String,
      messageText: String,
      date: Date)
    {
      self.id = id
      self.fromId = fromId
      self.toId = toId
      self.messageText = messageText
      self.date = date
    }
  }
}

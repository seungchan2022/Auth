import ComposableArchitecture
import DesignSystem
import Domain
import FirebaseAuth
import Foundation
import SwiftUI

// MARK: - ChatPage.MessageComponent

extension ChatPage {
  struct MessageComponent {
    let viewState: ViewState

    @Bindable var store: StoreOf<ChatReducer>
  }
}

extension ChatPage.MessageComponent { }

// MARK: - ChatPage.MessageComponent + View

extension ChatPage.MessageComponent: View {
  var body: some View {
    HStack {
      if viewState.isFromCurrentUser {
        Spacer()

        Text(viewState.item.messageText)
          .font(.subheadline)
          .padding()
          .background(Color(.systemBlue))
          .foregroundStyle(.white)
          .clipShape(
            .rect(
              topLeadingRadius: 12,
              bottomLeadingRadius: 12,
              bottomTrailingRadius: .zero,
              topTrailingRadius: 12))
          .padding(.leading, 32)

      } else {
        HStack(alignment: .bottom, spacing: 8) {
          RemoteImage(url: store.userInfo.photoURL ?? "") {
            Image(systemName: "person.circle.fill")
              .resizable()
              .frame(width: 24, height: 24)
              .clipShape(Circle())
          }
          .scaledToFill()
          .frame(width: 24, height: 24)
          .clipShape(Circle())

          Text(viewState.item.messageText)
            .font(.subheadline)
            .padding()
            .background(Color(.systemGray5))
            .foregroundStyle(.black)
            .clipShape(
              .rect(
                topLeadingRadius: 12,
                bottomLeadingRadius: .zero,
                bottomTrailingRadius: 12,
                topTrailingRadius: 12))
            .padding(.trailing, 32)
        }

        Spacer()
      }
    }
    .padding(.horizontal, 16)
  }
}

// MARK: - ChatPage.MessageComponent.ViewState

extension ChatPage.MessageComponent {
  struct ViewState: Equatable {
    let isFromCurrentUser: Bool
    let item: Chat.Message.Item

    init(item: Chat.Message.Item) {
      self.item = item
      isFromCurrentUser = item.fromId == Auth.auth().currentUser?.uid
    }

  }
}

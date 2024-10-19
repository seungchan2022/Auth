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
  }
}

extension ChatPage.MessageComponent {
  private var isImage: Bool {
    // 이미지 확장자 목록 정의
    let imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "webp"]
    // url이면서 이미지 확장자에 부합하는지 확인
    guard
      let url = URL(string: viewState.item.messageText),
      imageExtensions.contains(url.pathExtension.lowercased())
    else {
      return false
    }
    return true
  }

}

// MARK: - ChatPage.MessageComponent + View

extension ChatPage.MessageComponent: View {
  var body: some View {
    HStack {
      if viewState.isFromCurrentUser {
        Spacer()

        if isImage {
          RemoteImage(url: viewState.item.messageText) {
            ProgressView()
          }
          .clipShape(RoundedRectangle(cornerRadius: 10))
          .padding(.leading, 32)
        } else {
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
        }

      } else {
        HStack(alignment: .bottom, spacing: 8) {
          RemoteImage(url: viewState.user.photoURL ?? "") {
            Image(systemName: "person.circle.fill")
              .resizable()
              .frame(width: 24, height: 24)
              .clipShape(Circle())
          }
          .scaledToFill()
          .frame(width: 24, height: 24)
          .clipShape(Circle())

          if isImage {
            RemoteImage(url: viewState.item.messageText) {
              ProgressView()
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.trailing, 32)
          } else {
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
    let user: Authentication.Me.Response

    init(
      item: Chat.Message.Item,
      user: Authentication.Me.Response)
    {
      self.item = item
      self.user = user
      isFromCurrentUser = item.fromId == Auth.auth().currentUser?.uid
    }

  }
}

import DesignSystem
import Domain
import SwiftUI

// MARK: - ChatPage.ChatPartnerComponent

extension ChatPage {
  struct ChatPartnerComponent {
    let viewState: ViewState
  }
}

extension ChatPage.ChatPartnerComponent { }

// MARK: - ChatPage.ChatPartnerComponent + View

extension ChatPage.ChatPartnerComponent: View {
  var body: some View {
    VStack(alignment: .center, spacing: 8) {
      RemoteImage(url: viewState.user.photoURL ?? "") {
        Image(systemName: "person.circle.fill")
          .resizable()
          .frame(width: 120, height: 120)
          .clipShape(Circle())
          .foregroundStyle(.gray)
      }
      .scaledToFill()
      .frame(width: 120, height: 120)
      .clipShape(Circle())

      Text(viewState.user.userName ?? "")
        .font(.title3)
        .fontWeight(.semibold)

      Text("Messenger")
        .font(.subheadline)
        .foregroundStyle(.gray)
    }
  }
}

// MARK: - ChatPage.ChatPartnerComponent.ViewState

extension ChatPage.ChatPartnerComponent {
  struct ViewState: Equatable {
    let user: Authentication.Me.Response
  }
}

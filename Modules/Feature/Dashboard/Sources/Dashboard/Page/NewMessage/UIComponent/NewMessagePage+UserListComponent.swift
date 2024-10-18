import DesignSystem
import Domain
import SwiftUI

// MARK: - NewMessagePage.UserListComponent

extension NewMessagePage {
  struct UserListComponent {
    let viewState: ViewState
    let tapAction: (Authentication.Me.Response) -> Void
  }
}

extension NewMessagePage.UserListComponent { }

// MARK: - NewMessagePage.UserListComponent + View

extension NewMessagePage.UserListComponent: View {
  var body: some View {
    Button(action: { tapAction(viewState.user) }) {
      VStack {
        HStack {
          RemoteImage(url: viewState.user.photoURL ?? "") {
            Image(systemName: "person.circle.fill")
              .resizable()
              .frame(width: 40, height: 40)
              .clipShape(Circle())
          }
          .scaledToFill()
          .frame(width: 40, height: 40)
          .clipShape(Circle())

          Text(viewState.user.userName ?? "")
            .font(.callout)
            .fontWeight(.bold)

          Spacer()
        }
        .padding(.horizontal, 12)

        Divider()
          .padding(.leading, 64)
      }
    }
  }
}

// MARK: - NewMessagePage.UserListComponent.ViewState

extension NewMessagePage.UserListComponent {
  struct ViewState: Equatable {
    let user: Authentication.Me.Response
  }
}

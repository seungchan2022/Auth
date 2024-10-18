import DesignSystem
import Domain
import SwiftUI

// MARK: - HomePage.UserListComponent

extension HomePage {
  struct UserListComponent {
    let viewState: ViewState
    let tapAction: (Authentication.Me.Response) -> Void
  }
}

extension HomePage.UserListComponent { }

// MARK: - HomePage.UserListComponent + View

extension HomePage.UserListComponent: View {
  var body: some View {
    Button(action: { tapAction(viewState.user) }) {
      VStack(alignment: .center) {
        RemoteImage(url: viewState.user.photoURL ?? "") {
          Image(systemName: "person.circle.fill")
            .resizable()
            .frame(width: 64, height: 64)
            .foregroundStyle(.gray)
            .overlay(alignment: .bottomTrailing) {
              Circle()
                .fill(.white)
                .frame(width: 18, height: 18)

              Circle()
                .fill(.green)
                .frame(width: 12, height: 12)
            }
        }
        .scaledToFill()
        .frame(width: 64, height: 64)
        .clipShape(Circle())
        .overlay(alignment: .bottomTrailing) {
          Circle()
            .fill(.white)
            .frame(width: 18, height: 18)

          Circle()
            .fill(.green)
            .frame(width: 12, height: 12)
        }

        Text(viewState.user.userName ?? "")
          .font(.subheadline)
          .foregroundStyle(DesignSystemColor.palette(.gray(.lv400)).color)
          .lineLimit(.zero)
      }
      .frame(width: 80)
    }
  }
}

// MARK: - HomePage.UserListComponent.ViewState

extension HomePage.UserListComponent {
  struct ViewState: Equatable {
    let user: Authentication.Me.Response
  }
}

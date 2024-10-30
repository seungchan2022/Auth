import Architecture
import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

// MARK: - MePage.ProfileImageComponent

extension MePage {
  struct ProfileImageComponent {
    let viewState: ViewState
    let tapAction: () -> Void
  }
}

extension MePage.ProfileImageComponent {

  private var userName: String {
    guard let userName = viewState.user.userName
    else { return viewState.user.email?.components(separatedBy: "@").first ?? "" }
    return userName.isEmpty ? viewState.user.email?.components(separatedBy: "@").first ?? "" : userName
  }
}

// MARK: - MePage.ProfileImageComponent + View

extension MePage.ProfileImageComponent: View {
  var body: some View {
    Button(action: { tapAction() }) {
      VStack(alignment: .center) {
        RemoteImage(url: viewState.user.photoURL ?? "") {
          Image(systemName: "person.circle.fill")
            .resizable()
            .frame(width: 120, height: 120)
            .foregroundStyle(.gray)
            .overlay(alignment: .bottomTrailing) {
              Circle()
                .fill(.white)
                .frame(width: 30, height: 30)

              Image(systemName: "camera.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundStyle(.gray)
            }
        }
        .scaledToFill()
        .frame(width: 120, height: 120)
        .clipShape(Circle())
        .overlay(alignment: .bottomTrailing) {
          Circle()
            .fill(.white)
            .frame(width: 30, height: 30)

          Image(systemName: "camera.circle.fill")
            .resizable()
            .frame(width: 30, height: 30)
            .foregroundStyle(.gray)
        }

        Text(userName)
          .font(.title2)
          .fontWeight(.bold)

        Divider()
      }
      .foregroundStyle(.black)
    }
  }
}

// MARK: - MePage.ProfileImageComponent.ViewState

extension MePage.ProfileImageComponent {
  struct ViewState: Equatable {
    let user: Authentication.Me.Response
  }
}

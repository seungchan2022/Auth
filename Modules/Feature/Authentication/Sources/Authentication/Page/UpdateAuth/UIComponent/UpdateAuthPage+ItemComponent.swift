import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

// MARK: - UpdateAuthPage.ItemComponent

extension UpdateAuthPage {
  struct ItemComponent {
    let viewState: ViewState
    let nameTapAction: () -> Void
    let passwordTapAction: () -> Void
    let deleteTapAction: () -> Void

  }
}

extension UpdateAuthPage.ItemComponent {
  private var userName: String {
    guard let userName = viewState.user.userName
    else { return viewState.user.email?.components(separatedBy: "@").first ?? "" }
    return userName.isEmpty ? viewState.user.email?.components(separatedBy: "@").first ?? "" : userName
  }
}

// MARK: - UpdateAuthPage.ItemComponent + View

extension UpdateAuthPage.ItemComponent: View {
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        VStack(alignment: .leading, spacing: 16) {
          Text("이메일")

          Text(viewState.user.email ?? "")
        }

        Spacer()
      }
      .padding(.horizontal, 16)

      Divider()

      HStack {
        VStack(alignment: .leading, spacing: 16) {
          Text("이름")
          Text(userName)
        }

        Spacer()

        Button(action: { nameTapAction() }) {
          Text("변경")
        }
      }
      .padding(.horizontal, 16)

      Divider()

      HStack {
        VStack(alignment: .leading, spacing: 16) {
          Text("비밀번호")
          Text("************")
        }

        Spacer()

        Button(action: { passwordTapAction() }) {
          Text("변경")
        }
      }
      .padding(.horizontal, 16)

      Divider()

      Button(action: { deleteTapAction() }) {
        Text("계정 탈퇴")
          .padding(.top, 64)
      }
    }
  }
}

// MARK: - UpdateAuthPage.ItemComponent.ViewState

extension UpdateAuthPage.ItemComponent {
  struct ViewState: Equatable {
    let user: Authentication.Me.Response
  }
}

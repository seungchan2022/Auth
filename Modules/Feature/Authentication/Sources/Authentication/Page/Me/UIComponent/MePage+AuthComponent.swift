import DesignSystem
import Domain
import SwiftUI

// MARK: - MePage.AuthComponent

extension MePage {
  struct AuthComponent {
    let viewState: ViewState
    let tapAction: () -> Void
  }
}

extension MePage.AuthComponent { }

// MARK: - MePage.AuthComponent + View

extension MePage.AuthComponent: View {
  var body: some View {
    VStack(spacing: 32) {
      Button(action: { tapAction() }) {
        VStack {
          HStack {
            Image(systemName: "lock.square")
              .resizable()
              .foregroundStyle(.black)
              .frame(width: 20, height: 20)

            Text("로그인 / 보안")
              .font(.headline)
              .foregroundStyle(.black)

            Spacer()
          }
          .padding(.horizontal, 16)

          Divider()
        }
      }
    }
    .padding(.top, 32)
  }
}

// MARK: - MePage.AuthComponent.ViewState

extension MePage.AuthComponent {
  struct ViewState: Equatable { }
}

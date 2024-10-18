import ComposableArchitecture
import DesignSystem
import Functor
import SwiftUI

// MARK: - Focus

enum Focus {
  case currPassword
  case newPassword
  case confirmPassword
}

// MARK: - UpdatePasswordPage

struct UpdatePasswordPage {
  @Bindable var store: StoreOf<UpdatePasswordReducer>
  @FocusState private var isFocused: Focus?

}

extension UpdatePasswordPage {

  private var isActiveUpdatePassword: Bool {
    Validator.validatePassword(password: store.newPasswordText)
      && isValidConfirmPassword(text: store.confirmPasswordText)
  }

  private var isLoading: Bool {
    store.fetchUpdatePassword.isLoading
  }

  private func isValidConfirmPassword(text: String) -> Bool {
    store.newPasswordText == text
  }
}

// MARK: View

extension UpdatePasswordPage: View {
  var body: some View {
    VStack {
      DesignSystemNavigation(
        barItem: .init(
          backAction: .init(
            image: Image(systemName: "xmark"),
            action: { store.send(.routeToClose) }),
          title: "비밀번호 변경",
          moreActionList: []),
        isShowDivider: true)
      {
        VStack(spacing: 32) {
          TextFieldComponent(
            viewState: .init(),
            title: "현재 비밀번호",
            placeholder: "현재 비밀번호",
            isSecure: !store.isShowCurrPassword,
            errorMessage: .none,
            toggleAction: { store.isShowCurrPassword.toggle() },
            isFocused: $isFocused,
            focusType: .currPassword,
            text: $store.currPasswordText)

          TextFieldComponent(
            viewState: .init(),
            title: "변경할 비밀번호",
            placeholder: "변경할 비밀번호",
            isSecure: !store.isShowNewPassword,
            errorMessage: store.isValidPassword ? .none : "영어대문자, 숫자, 특수문자를 모두 사용하여 8 ~ 20자리로 설정해주세요.",
            toggleAction: { store.isShowNewPassword.toggle() },
            isFocused: $isFocused,
            focusType: .newPassword,
            text: $store.newPasswordText)
            .onChange(of: store.newPasswordText) { _, new in
              store.isValidPassword = Validator.validatePassword(password: new)
            }

          TextFieldComponent(
            viewState: .init(),
            title: "비밀번호 확인",
            placeholder: "비밀번호 확인",
            isSecure: !store.isShowConfirmPassword,
            errorMessage: store.isValidConfirmPassword ? .none : "비밀번호가 일치하지 않습니다.",
            toggleAction: { store.isShowConfirmPassword.toggle() },
            isFocused: $isFocused,
            focusType: .confirmPassword,
            text: $store.confirmPasswordText)
            .onChange(of: store.confirmPasswordText) { _, new in
              store.isValidConfirmPassword = isValidConfirmPassword(text: new)
            }

          Button(action: { store.send(.onTapUpdatePassword) }) {
            Text("비밀번호 변경")
              .foregroundStyle(.white)
              .frame(height: 50)
              .frame(maxWidth: .infinity)
              .background(.blue)
              .clipShape(RoundedRectangle(cornerRadius: 8))
              .opacity(isActiveUpdatePassword ? 1.0 : 0.3)
          }
          .disabled(!isActiveUpdatePassword)
        }
        .padding(16)
      }
    }

    .toolbar(.hidden, for: .navigationBar)
    .setRequestFlightView(isLoading: isLoading)
    .onAppear {
      isFocused = .currPassword
    }
    .onDisappear {
      store.send(.teardown)
    }
  }
}

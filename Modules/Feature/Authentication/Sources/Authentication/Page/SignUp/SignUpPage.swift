import ComposableArchitecture
import DesignSystem
import Functor
import SwiftUI

// MARK: - SignUpFocus

enum SignUpFocus {
  case email
  case password
  case confirmPassword
}

// MARK: - SignUpPage

struct SignUpPage {
  @Bindable var store: StoreOf<SignUpReducer>

  @FocusState private var isFocused: SignUpFocus?

}

extension SignUpPage {
  private var isActiveSignUp: Bool {
    Validator.validateEmail(email: store.emailText)
      && Validator.validatePassword(password: store.passwordText)
      && isValidConfirmPassword(text: store.confirmPasswordText)
  }

  private func isValidConfirmPassword(text: String) -> Bool {
    store.passwordText == text
  }
}

// MARK: View

extension SignUpPage: View {
  var body: some View {
    VStack {
      DesignSystemNavigation(
        barItem: .init(
          backAction: .init(image: Image(systemName: "chevron.left"), action: { store.send(.routeToSignIn) }),
          title: "회원가입"),
        isShowDivider: true)
      {
        VStack(spacing: 32) {
          TextFieldComponent(
            viewState: .init(),
            title: "이메일 주소",
            placeholder: "이메일",
            isSecure: false,
            errorMessage: store.isValidEmail ? .none : "유효한 이메일 주소가 아닙니다.",
            toggleAction: .none,
            isFocused: $isFocused,
            focusType: .email,
            text: $store.emailText)
            .onChange(of: store.emailText) { _, new in
              store.isValidEmail = Validator.validateEmail(email: new)
            }

          TextFieldComponent(
            viewState: .init(),
            title: "비밀번호",
            placeholder: "비밀번호",
            isSecure: !store.isShowPassword,
            errorMessage: store.isValidPassword ? .none : "영어대문자, 숫자, 특수문자를 모두 사용하여 8 ~ 20자리로 설정해주세요.",
            toggleAction: { store.isShowPassword.toggle() },
            isFocused: $isFocused,
            focusType: .password,
            text: $store.passwordText)
            .onChange(of: store.passwordText) { _, new in
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

          Button(action: { store.send(.onTapSignUp) }) {
            Text("회원 가입")
              .foregroundStyle(.white)
              .frame(height: 50)
              .frame(maxWidth: .infinity)
              .background(.blue)
              .clipShape(RoundedRectangle(cornerRadius: 8))
              .opacity(isActiveSignUp ? 1.0 : 0.3)
          }
          .disabled(!isActiveSignUp)
        }
        .padding(16)
      }
    }
    .toolbar(.hidden, for: .navigationBar)
    .onAppear {
      isFocused = .email
    }
    .onDisappear {
      store.send(.teardown)
    }
  }
}

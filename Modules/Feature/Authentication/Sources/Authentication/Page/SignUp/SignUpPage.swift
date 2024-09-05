import ComposableArchitecture
import DesignSystem
import Functor
import SwiftUI

// MARK: - Focus

private enum Focus {
  case email
  case password
  case confirmPassword
}

// MARK: - SignUpPage

struct SignUpPage {
  @Bindable var store: StoreOf<SignUpReducer>

  @FocusState private var isFocus: Focus?

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
          VStack(alignment: .leading, spacing: 16) {
            Text("이메일 주소")

            TextField(
              "이메일",
              text: $store.emailText)
              .textInputAutocapitalization(.never)
              .autocorrectionDisabled(true)
              .onChange(of: store.emailText) { _, new in
                store.isValidEmail = Validator.validateEmail(email: new)
              }

            Divider()
              .overlay(!store.isValidEmail ? .red : isFocus == .email ? .blue : .clear)

            if !store.isValidEmail {
              HStack {
                Text("유효한 이메일 주소가 아닙니다.")
                  .font(.footnote)
                  .foregroundStyle(.red)

                Spacer()
              }
            }
          }
          .focused($isFocus, equals: .email)

          VStack(alignment: .leading, spacing: 16) {
            Text("비밀번호")

            Group {
              if store.isShowPassword {
                TextField(
                  "비밀번호",
                  text: $store.passwordText)
              } else {
                SecureField(
                  "비밀번호",
                  text: $store.passwordText)
              }
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .onChange(of: store.passwordText) { _, new in
              store.isValidPassword = Validator.validatePassword(password: new)
            }

            Divider()
              .overlay(!store.isValidPassword ? .red : isFocus == .password ? .blue : .clear)

            if !store.isValidPassword {
              HStack {
                Text("영어대문자, 숫자, 특수문자를 모두 사용하여 8 ~ 20자리로 설정해주세요.")
                  .font(.footnote)
                  .foregroundStyle(.red)

                Spacer()
              }
            }
          }
          .focused($isFocus, equals: .password)
          .overlay(alignment: .trailing) {
            Button(action: { store.isShowPassword.toggle() }) {
              Image(systemName: store.isShowPassword ? "eye" : "eye.slash")
                .foregroundStyle(.black)
                .padding(.trailing, 12)
            }
          }

          VStack(alignment: .leading, spacing: 16) {
            Text("비밀번호 확인")

            Group {
              if store.isShowConfirmPassword {
                TextField(
                  "비밀번호 확인",
                  text: $store.confirmPasswordText)
              } else {
                SecureField(
                  "비밀번호 확인",
                  text: $store.confirmPasswordText)
              }
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .onChange(of: store.confirmPasswordText) { _, new in
              store.isValidConfirmPassword = isValidConfirmPassword(text: new)
            }

            Divider()
              .overlay(!store.isValidConfirmPassword ? .red : isFocus == .confirmPassword ? .blue : .clear)

            if !store.isValidConfirmPassword {
              HStack {
                Text("비밀번호가 일치하지 않습니다.")
                  .font(.footnote)
                  .foregroundStyle(.red)

                Spacer()
              }
            }
          }
          .focused($isFocus, equals: .confirmPassword)
          .overlay(alignment: .trailing) {
            Button(action: { store.isShowConfirmPassword.toggle() }) {
              Image(systemName: store.isShowConfirmPassword ? "eye" : "eye.slash")
                .foregroundStyle(.black)
                .padding(.trailing, 12)
            }
          }

          Button(action: { }) {
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
      isFocus = .email
    }
    .onDisappear {
      store.send(.teardown)
    }
  }
}

// MARK: - Validator

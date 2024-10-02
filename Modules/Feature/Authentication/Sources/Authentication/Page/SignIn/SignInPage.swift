import AuthenticationServices
import ComposableArchitecture
import CryptoKit
import DesignSystem
import Domain
import FirebaseAuth
import GoogleSignInSwift
import SwiftUI

// MARK: - Focus

private enum Focus {
  case email
  case password
}

// MARK: - SignInPage

struct SignInPage {
  @Bindable var store: StoreOf<SignInReducer>

  @FocusState private var isFocus: Focus?

  @Environment(\.colorScheme) var colorScheme

  @State private var currentNonce: String?
}

extension SignInPage {

  // MARK: Internal

  func startSignInWithAppleFlow() {
    let nonce = randomNonceString()
    currentNonce = nonce
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    request.requestedScopes = [.fullName, .email]
    request.nonce = sha256(nonce)
  }

  // MARK: Private

  private var isActiveSignIn: Bool {
    !store.emailText.isEmpty && !store.passwordText.isEmpty
  }

  private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    var randomBytes = [UInt8](repeating: 0, count: length)
    let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
    if errorCode != errSecSuccess {
      fatalError(
        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
    }

    let charset: [Character] =
      Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

    let nonce = randomBytes.map { byte in
      // Pick a random character from the set, wrapping around if needed.
      charset[Int(byte) % charset.count]
    }

    return String(nonce)
  }

  @available(iOS 13, *)
  private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
      String(format: "%02x", $0)
    }.joined()

    return hashString
  }

}

// MARK: View

extension SignInPage: View {
  var body: some View {
    VStack {
      DesignSystemNavigation(
        barItem: .init(
          backAction: .init(image: Image(systemName: "chevron.left"), action: { store.send(.routeToBack) }),
          title: "로그인"),
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

            Divider()
              .overlay(isFocus == .email ? .blue : .clear)
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

            Divider()
              .overlay(isFocus == .password ? .blue : .clear)
          }
          .focused($isFocus, equals: .password)
          .overlay(alignment: .trailing) {
            Button(action: { store.isShowPassword.toggle() }) {
              Image(systemName: store.isShowPassword ? "eye" : "eye.slash")
                .foregroundStyle(.black)
                .padding(.trailing, 12)
            }
          }

          Button(action: { store.send(.onTapSignIn) }) {
            Text("로그인")
              .foregroundStyle(.white)
              .frame(height: 50)
              .frame(maxWidth: .infinity)
              .background(.blue)
              .clipShape(RoundedRectangle(cornerRadius: 8))
              .opacity(isActiveSignIn ? 1.0 : 0.3)
          }
          .disabled(!isActiveSignIn)

          HStack {
            Spacer()
            Button(action: {
              store.resetEmailText = ""
              store.isShowResetPassword = true
            }) {
              Text("비밀번호 재설정")
            }

            Spacer()

            Divider()

            Spacer()

            Button(action: { store.send(.routeToSignUp) }) {
              Text("회원 가입")
            }

            Spacer()
          }
          .padding(.top, 8)

          SignInWithAppleButton(
            onRequest: { request in
              let nonce = randomNonceString() // Apple 로그인에 사용할 nonce를 생성
              currentNonce = nonce
              request.requestedScopes = [.fullName, .email]
              request.nonce = sha256(nonce)
            },
            onCompletion: { result in
              switch result {
              case .success(let auth):
                if let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential {
                  // nonce 값이 일치하는지 확인
                  guard let nonce = currentNonce else {
                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                  }

                  // Firebase 인증을 위한 토큰 생성
                  guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetch identity token")
                    return
                  }
                  guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return
                  }

                  // Firebase에 사용할 인증 정보 생성
                  let credential = OAuthProvider.appleCredential(
                    withIDToken: idTokenString,
                    rawNonce: nonce,
                    fullName: appleIDCredential.fullName)

                  // Sign in with Firebase.
                  Auth.auth().signIn(with: credential) { _, error in
                    if let error = error {
                      // 에러 처리
                      print(error.localizedDescription)
                      return
                    }

                    store.send(.routeToMe)
                  }
                }

              case .failure(let error):
                print("\(error.localizedDescription)")
              }
            })
            .frame(height: 50)
            .padding(.horizontal, 16)
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)

          GoogleSignInButton(
            viewModel: .init(
              scheme: .dark,
              style: .wide,
              state: .normal),
            action: { store.send(.onTapGoogleSignIn) })
        }
        .padding(16)
      }
    }
    .alert(
      "비밀번호 재설정",
      isPresented: $store.isShowResetPassword,
      actions: {
        TextField("이메일", text: $store.resetEmailText)
          .autocorrectionDisabled(true)
          .textInputAutocapitalization(.never)

        Button(role: .cancel, action: { store.isShowResetPassword = false }) {
          Text("취소")
        }

        Button(action: { store.send(.onTapResetPassword) }) {
          Text("확인")
        }
      },
      message: {
        Text("계정과 연결된 이메일 주소를 입력하면, 비밀번호 재설정 링크가 이메일로 전송됩니다.")
      })
    .toolbar(.hidden, for: .navigationBar)
    .onAppear {
      isFocus = .email
    }
    .onDisappear {
      store.send(.teardown)
    }
  }
}

import ComposableArchitecture
import DesignSystem
import SwiftUI

// MARK: - UpdateAuthPage

struct UpdateAuthPage {
  @Bindable var store: StoreOf<UpdateAuthReducer>

}

extension UpdateAuthPage {

  private var userName: String {
    guard let userName = store.user.userName else { return "이름을 설정해주세요." }
    return userName.isEmpty ? "이름을 설정해주세요." : userName
  }
}

// MARK: View

extension UpdateAuthPage: View {
  var body: some View {
    VStack {
      DesignSystemNavigation(
        barItem: .init(
          backAction: .init(
            image: Image(systemName: "chevron.left"),
            action: { store.send(.routeToBack) }),
          title: "로그인/보안",
          moreActionList: [
            .init(title: "로그아웃", action: { store.isShowSignOutAlert = true }),
          ]),
        isShowDivider: true)
      {
        VStack(spacing: 16) {
          HStack {
            VStack(alignment: .leading, spacing: 16) {
              Text("이메일")

              Text(store.user.email ?? "")
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

            Button(action: {
              store.updateUserName = ""
              store.isShowUpdateUserNameAlert = true
            }) {
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

            Button(action: { store.send(.routeToUpdatePassword) }) {
              Text("변경")
            }
          }
          .padding(.horizontal, 16)

          Divider()
        }
      }
    }
    .overlay(alignment: .bottom) {
      Button(action: {
        store.passwordText = ""
        store.isShowDeleteUserAlert = true
      }) {
        Text("계정 탈퇴")
      }
      .padding(.bottom, 64)
      .padding(.top, 32)
    }
    .alert(
      "이름을 변경하시겠습니까?",
      isPresented: $store.isShowUpdateUserNameAlert)
    {
      TextField("이름", text: $store.updateUserName)
        .autocorrectionDisabled(true)
        .textInputAutocapitalization(.never)

      Button(action: { store.send(.onTapUpdateUserName) }) {
        Text("확인")
      }

      Button(role: .cancel, action: { store.isShowUpdateUserNameAlert = false }) {
        Text("취소")
      }
    } message: {
      Text("변경하고 싶은 이름을 작성하시고, 확인 버튼을 눌러주세요.")
    }
    .alert(
      "로그아웃을 하시겠습니까?",
      isPresented: $store.isShowSignOutAlert)
    {
      Button(action: { store.send(.onTapSignOut) }) {
        Text("확인")
      }

      Button(role: .cancel, action: { store.isShowSignOutAlert = false }) {
        Text("취소")
      }
    } message: {
      Text("로그아웃을 하려면 확인 버튼을 눌러주세요.")
    }
    .alert(
      "계정을 탈퇴하시겟습니까?",
      isPresented: $store.isShowDeleteUserAlert)
    {
      TextField("비밀번호", text: $store.passwordText)
        .autocorrectionDisabled(true)
        .textInputAutocapitalization(.never)

      Button(action: { }) {
        Text("확인")
      }

      Button(role: .cancel, action: { store.isShowDeleteUserAlert = false }) {
        Text("취소")
      }
    } message: {
      Text("계정을 탈퇴 하려면 확인 버튼을 눌러주세요.")
    }
    .toolbar(.hidden, for: .navigationBar)
    .onAppear {
      store.send(.getUser)
    }
    .onDisappear {
      store.send(.teardown)
    }
  }
}

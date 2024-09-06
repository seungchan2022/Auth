import Architecture
import ComposableArchitecture
import DesignSystem
import SwiftUI

// MARK: - MePage

struct MePage {
  @Bindable var store: StoreOf<MeReducer>
}

extension MePage {
  private var userName: String {
    guard let userName = store.user.userName else { return "이름을 설정해주세요." }
    return userName.isEmpty ? "이름을 설정해주세요." : userName
  }
}

// MARK: View

extension MePage: View {
  var body: some View {
    VStack {
      DesignSystemNavigation(
        barItem: .init(title: ""),
        largeTitle: "Me")
      {
        VStack {
          Button(action: { }) {
            VStack(alignment: .leading) {
              HStack(spacing: 12) {
                RemoteImage(url: store.user.photoURL ?? "") {
                  Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .fontWeight(.ultraLight)
                }
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(Circle())

                VStack(alignment: .leading) {
                  Text("이메일: \(store.user.email ?? "")")

                  Text("이름: \(userName)")
                }

                Spacer()

                Image(systemName: "chevron.right")
                  .resizable()
                  .frame(width: 14, height: 20)
              }
              .padding(.horizontal, 16)

              Divider()
            }
            .foregroundStyle(.black)
          }

          .frame(maxWidth: .infinity, alignment: .leading)
          .onTapGesture { }

          VStack(spacing: 32) {
            Button(action: {  }) {
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

                  Image(systemName: "chevron.right")
                    .resizable()
                    .fontWeight(.light)
                    .foregroundStyle(.black)
                    .frame(width: 14, height: 20)
                }
                .padding(.horizontal, 16)

                Divider()
              }
            }
          }
          .padding(.top, 32)
        }
        .padding(.vertical, 16)
      }
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

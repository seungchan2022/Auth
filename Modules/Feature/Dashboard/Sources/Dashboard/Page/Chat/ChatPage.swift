import ComposableArchitecture
import DesignSystem
import SwiftUI

// MARK: - ChatPage

struct ChatPage {
  @Bindable var store: StoreOf<ChatReducer>

  @State private var messageText = ""

}

extension ChatPage { }

// MARK: View

extension ChatPage: View {
  var body: some View {
    VStack {
      DesignSystemNavigation(
        barItem: .init(
          backAction: .init(
            image: Image(systemName: "chevron.left"),
            action: { store.send(.routeToBack) }),
          title: (store.userInfo.userName ?? "").uppercased()),
        isShowDivider: true)
      {
        // 전체
        VStack {
          // 채팅 보낼 유저 정보
          VStack(alignment: .center, spacing: 8) {
            RemoteImage(url: store.userInfo.photoURL ?? "") {
              Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .foregroundStyle(.gray)
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())

            Text(store.userInfo.userName ?? "")
              .font(.title3)
              .fontWeight(.semibold)

            Text("Messenger")
              .font(.subheadline)
              .foregroundStyle(.gray)
          }

          // 채팅 메시지 내용
          LazyVStack(spacing: 16) {
            ForEach(0..<15) { _ in
              ChatPage.MessageComponent(viewState: .init(isFromCurrentUser: Bool.random()))
            }
          }
          .padding(.top, 32)
        }
      }

      HStack {
        TextField("Message..", text: $messageText, axis: .vertical)
          .padding(12)

        Spacer()

        Button(action: { }) {
          Text("Send")
            .padding(.trailing, 8)
        }
        .disabled(
          messageText.isEmpty ? true : false)
      }
      .background(Color(.systemGroupedBackground))
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .padding(.horizontal, 12)
    }
    .toolbar(.hidden, for: .navigationBar)
    .onAppear {
      store.send(.getUserInfo(store.userInfo))
    }
    .onDisappear {
      store.send(.teardown)
    }
  }
}

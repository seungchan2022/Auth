import ComposableArchitecture
import DesignSystem
import FirebaseAuth
import PhotosUI
import SwiftUI

// MARK: - ChatPage

struct ChatPage {
  @Bindable var store: StoreOf<ChatReducer>

  @Namespace var lastMessage
}

extension ChatPage {
  private var message: String {
    store.itemList.last?.messageText ?? ""
  }
}

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
        ScrollViewReader { proxy in
          VStack {
            // 채팅 보낼 유저 정보
            ChatPartnerComponent(viewState: .init(user: store.userInfo))

            // 채팅 메시지 내용
            LazyVStack(spacing: 16) {
              ForEach(store.itemList, id: \.id) { item in

                MessageComponent(
                  viewState: .init(
                    item: item,
                    user: store.userInfo))
                .onAppear {
                  if item.id == store.itemList.last?.id {
                    withAnimation {
                      proxy.scrollTo(lastMessage, anchor: .bottom)
                    }
                  }
                }
              }
            }
            .padding(.top, 32)
          }
          .padding(.bottom, 32)
          .id(lastMessage)
          .onChange(of: message) { _, _ in
            withAnimation {
              proxy.scrollTo(lastMessage, anchor: .bottom)
            }
          }
        }
      }

      HStack {
        Button(action: { store.isShowPhotosPicker = true }) {
          Image(systemName: "photo")
            .renderingMode(.template)
            .imageScale(.large)
        }
        .photosPicker(
          isPresented: $store.isShowPhotosPicker,
          selection: $store.selectedImage)
        .onChange(of: store.selectedImage) { _, new in
          Task {
            guard let item = new else { return }
            guard let imageData = try? await item.loadTransferable(type: Data.self) else { return }

            store.send(.sendImageMessage(imageData))
            store.selectedImage = .none
          }
        }

        HStack {
          TextField("Message..", text: $store.messageText, axis: .vertical)
            .padding(12)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)

          Spacer()

          Button(action: {
            store.send(.onTapSendMessage(store.messageText))
            store.send(.getItemList)
            store.messageText = ""
          }) {
            Text("Send")
              .padding(.trailing, 8)
          }
          .disabled(
            store.messageText.isEmpty ? true : false)
        }
        .background(Color(.systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 8)
      }
      .padding(.horizontal, 12)
    }
    .toolbar(.hidden, for: .navigationBar)
    .onAppear {
      store.send(.getUserInfo(store.userInfo))
      store.send(.getItemList)
    }
    .onDisappear {
      store.send(.teardown)
    }
  }
}

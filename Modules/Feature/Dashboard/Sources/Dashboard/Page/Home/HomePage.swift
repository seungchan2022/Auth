import ComposableArchitecture
import DesignSystem
import FirebaseAuth
import SwiftUI

// MARK: - HomePage

struct HomePage {
  @Bindable var store: StoreOf<HomeReducer>

  @State private var isEditingFocus: String? = .none
}

extension HomePage {
  private var profileImageURL: String {
    Auth.auth().currentUser?.photoURL?.absoluteString ?? ""
  }
}

// MARK: View

extension HomePage: View {
  var body: some View {
    VStack {
      DesignSystemNavigation(
        barItem: .init(
          backAction: .init(
            image: Image(systemName: "person.circle.fill"),
            action: { store.send(.routeToMe) }),
          moreActionList: [
            .init(
              image: Image(systemName: "square.and.pencil"),
              action: { store.send(.routeToNewMessage) }),
          ]),
        largeTitle: "Home")
      {
        VStack {
          ScrollView(.horizontal) {
            LazyHStack(spacing: 16) {
              ForEach(store.userList, id: \.uid) { user in
                UserListComponent(
                  viewState: .init(user: user),
                  tapAction: { store.send(.routeToChat($0)) })
              }
            }
            .padding(.horizontal, 16)
          }
          .scrollIndicators(.hidden)

          LazyVStack(spacing: 8) {
            ForEach(store.recentMessageList.sorted(by: { $0.date > $1.date })) { item in
              if let user = store.userList.first(where: { $0.uid == item.fromId || $0.uid == item.toId }) {
                RecentMessageComponent(
                  viewState: .init(
                    item: item,
                    userList: store.userList,
                    chatPartnerId: user.uid,
                    isEdit: isEditingFocus == item.id),
                  tapAction: { store.send(.routeToChat(user)) },
                  swipeAction: { self.isEditingFocus = $0 },
                  deleteAction: { store.send(.onTapDeleteMessage($0)) })
              }
            }
          }
          .animation(.default, value: store.recentMessageList)
          .padding(.top, 32)
        }
      }
    }
    .toolbar(.hidden, for: .navigationBar)
    .onAppear {
      store.send(.getUserList)
      store.send(.getRecentMessageList)
    }
    .onDisappear {
      store.send(.teardown)
    }
  }
}

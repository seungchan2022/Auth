import ComposableArchitecture
import DesignSystem
import FirebaseAuth
import SwiftUI

// MARK: - HomePage

struct HomePage {
  @Bindable var store: StoreOf<HomeReducer>
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
                Button(action: { store.send(.routeToChat(user)) }) {
                  VStack(alignment: .center) {
                    RemoteImage(url: user.photoURL ?? "") {
                      Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 64, height: 64)
                        .foregroundStyle(.gray)
                        .overlay(alignment: .bottomTrailing) {
                          Circle()
                            .fill(.white)
                            .frame(width: 18, height: 18)

                          Circle()
                            .fill(.green)
                            .frame(width: 12, height: 12)
                        }
                    }
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
                    .overlay(alignment: .bottomTrailing) {
                      Circle()
                        .fill(.white)
                        .frame(width: 18, height: 18)

                      Circle()
                        .fill(.green)
                        .frame(width: 12, height: 12)
                    }

                    Text(user.userName ?? "")
                      .font(.subheadline)
                      .foregroundStyle(DesignSystemColor.palette(.gray(.lv400)).color)
                      .lineLimit(.zero)
                  }
                  .frame(width: 80)
                }
              }
            }
            .padding(.horizontal, 16)
          }
          .scrollIndicators(.hidden)

          LazyVStack(spacing: 8) {
            ForEach(store.recentMessageList.sorted(by: { $0.date > $1.date })) { item in
              RecentMessageComponent(
                viewState: .init(item: item),
                tapAction: {
                  if let user = store.userList.first(where: { $0.uid == item.fromId || $0.uid == item.toId }) {
                    store.send(.routeToChat(user))
                  }
                },
                store: store)
            }
          }
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

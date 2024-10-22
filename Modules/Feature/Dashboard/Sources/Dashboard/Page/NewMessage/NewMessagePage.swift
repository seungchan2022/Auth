import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

// MARK: - NewMessagePage

struct NewMessagePage {
  @Bindable var store: StoreOf<NewMessageReducer>

}

extension NewMessagePage {
  private var userList: [Authentication.Me.Response] {
    guard !store.searchText.isEmpty else { return store.userList }

    return store.userList.filter {
      guard let userName = $0.userName else { return false }
      return userName.lowercased().contains(store.searchText.lowercased())
    }
  }
}

// MARK: View

extension NewMessagePage: View {
  var body: some View {
    VStack {
      DesignSystemNavigation(
        barItem: .init(
          backAction: .init(
            image: Image(systemName: "xmark"),
            action: { store.send(.routeToClose) }),
          title: "New Message"),
        isShowDivider: true)
      {
        VStack(alignment: .leading, spacing: 32) {
          TextField("To: ", text: $store.searchText)
            .frame(height: 48)
            .padding(.leading, 12)
            .background(.gray.opacity(0.3))
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

          Text("CONTACTS")
            .font(.callout)
            .foregroundStyle(.gray)
            .padding(.leading, 12)

          Divider()

          LazyVStack(spacing: 8) {
            ForEach(userList, id: \.uid) { user in
              UserListComponent(
                viewState: .init(user: user),
                tapAction: { store.send(.routeToChat($0)) })
            }
          }
        }
      }
    }
    .toolbar(.hidden, for: .navigationBar)
    .onAppear {
      store.send(.getUserList)
    }
    .onDisappear {
      store.send(.teardown)
    }
  }
}

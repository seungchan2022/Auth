import ComposableArchitecture
import DesignSystem
import SwiftUI

// MARK: - NewMessagePage

struct NewMessagePage {
  @Bindable var store: StoreOf<NewMessageReducer>

  @State private var searchText = ""
}

extension NewMessagePage { }

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
          TextField("To: ", text: $searchText)
            .frame(height: 48)
            .padding(.leading, 12)
            .background(.gray.opacity(0.3))

          Text("CONTACTS")
            .font(.callout)
            .foregroundStyle(.gray)
            .padding(.leading, 12)

          Divider()

          LazyVStack(spacing: 8) {
            ForEach(0..<20) { _ in
              Button(action: { store.send(.routeToChat) }) {
                VStack {
                  HStack {
                    Image(systemName: "person.circle.fill")
                      .resizable()
                      .frame(width: 40, height: 40)

                    Text("메시지를 보낼 유저 이름")
                      .font(.callout)
                      .fontWeight(.bold)

                    Spacer()
                  }
                  .padding(.horizontal, 12)

                  Divider()
                    .padding(.leading, 64)
                }
              }
            }
          }
        }
      }
    }
    .toolbar(.hidden, for: .navigationBar)
    .onAppear { }
    .onDisappear {
      store.send(.teardown)
    }
  }
}

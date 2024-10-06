import ComposableArchitecture
import DesignSystem
import SwiftUI

// MARK: - HomePage

struct HomePage {
  @Bindable var store: StoreOf<HomeReducer>
}

extension HomePage { }

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
        largeTitle: "Chat")
      {
        VStack {
          ScrollView(.horizontal) {
            LazyHStack(spacing: 16) {
              ForEach(0..<5) { _ in
                Button(action: { store.send(.routeToChat) }) {
                  VStack(alignment: .center) {
                    Image(systemName: "person.circle.fill")
                      .resizable()
                      .frame(width: 64, height: 64)
                      .foregroundStyle(Color(.systemGray))

                      .overlay(alignment: .bottomTrailing) {
                        Circle()
                          .fill(.white)
                          .frame(width: 18, height: 18)
                        Circle()
                          .fill(.green)
                          .frame(width: 12, height: 12)
                      }

                    Text("UserNam333e")
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
            ForEach(0..<5) { _ in
              Button(action: { store.send(.routeToChat) }) {
                VStack {
                  HStack {
                    Image(systemName: "person.circle.fill")
                      .resizable()
                      .frame(width: 64, height: 64)

                    VStack(alignment: .leading) {
                      Text("메시지를 보낸 유저 이름")
                        .font(.callout)
                        .fontWeight(.bold)

                      Text(
                        "메시지 내용 메시지 내용메시지 내용 메시지 내용메시지 내용메시지 내용메시지 내용, 메시지 내용, 메시지 내용, 메시지 내용., 내용 메시지 내용메시지 내용 메시지 내용메시지 내용메시지 내용메시지 내용, 메시지 내용, 메시지 내용, 메시지 내용.,")
                        .font(.footnote)
                        .lineLimit(.zero)
                    }

                    Spacer()

                    HStack {
                      Text("보낸 날짜")

                      Image(systemName: "chevron.right")
                        .imageScale(.small)
                    }
                  }
                  .padding(.horizontal, 12)

                  Divider()
                    .padding(.leading, 80)
                }
                .frame(maxWidth: .infinity)
              }
            }
          }
          .padding(.top, 32)
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

import Architecture
import ComposableArchitecture
import DesignSystem
import PhotosUI
import SwiftUI

// MARK: - MePage

struct MePage {
  @Bindable var store: StoreOf<MeReducer>
}

extension MePage {
  private var userName: String {
    guard let userName = store.user.userName
    else { return String(store.user.email?.split(separator: "@").first ?? "") }
    return userName.isEmpty ? String(store.user.email?.split(separator: "@").first ?? "") : userName
  }

  private var isLoading: Bool {
    store.fetchUser.isLoading
      || store.fetchUpdateProfileImage.isLoading
  }
}

// MARK: View

extension MePage: View {
  var body: some View {
    VStack {
      DesignSystemNavigation(
        barItem: .init(
          backAction: .init(
            image: Image(systemName: "chevron.left"),
            action: { store.send(.routeToBack) })))
      {
        VStack {
          Button(action: { store.isShowPhotsPicker = true }) {
            VStack(alignment: .center) {
              RemoteImage(url: store.user.photoURL ?? "") {
                Image(systemName: "person.circle.fill")
                  .resizable()
                  .frame(width: 120, height: 120)
                  .foregroundStyle(.gray)
                  .overlay(alignment: .bottomTrailing) {
                    Circle()
                      .fill(.white)
                      .frame(width: 40, height: 40)

                    Image(systemName: "camera.circle.fill")
                      .resizable()
                      .frame(width: 40, height: 40)
                      .foregroundStyle(.gray)
                  }
              }
              .scaledToFill()
              .frame(width: 120, height: 120)
              .clipShape(Circle())
              .overlay(alignment: .bottomTrailing) {
                Circle()
                  .fill(.white)
                  .frame(width: 40, height: 40)

                Image(systemName: "camera.circle.fill")
                  .resizable()
                  .frame(width: 40, height: 40)
                  .foregroundStyle(.gray)
              }

              Text("\(userName)")
                .font(.title2)
                .fontWeight(.bold)

              Divider()
            }
            .foregroundStyle(.black)
          }
          .photosPicker(
            isPresented: $store.isShowPhotsPicker,
            selection: $store.selectedImage)
          .onChange(of: store.selectedImage) { _, new in
            Task {
              guard let item = new else { return }
              guard let imageData = try? await item.loadTransferable(type: Data.self) else { return }

              store.send(.updateProfileImage(imageData))
            }
          }

          VStack(spacing: 32) {
            Button(action: { store.send(.routeToUpdateAuth) }) {
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
                }
                .padding(.horizontal, 16)

                Divider()
              }
            }
          }
          .padding(.top, 32)
        }
      }
    }
    .toolbar(.hidden, for: .navigationBar)
    .setRequestFlightView(isLoading: isLoading)
    .onAppear {
      store.send(.getUser)
    }
    .onDisappear {
      store.send(.teardown)
    }
  }
}

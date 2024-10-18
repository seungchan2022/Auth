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
          ProfileImageComponent(
            viewState: .init(user: store.user),
            tapAction: { store.isShowPhotsPicker = true })
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

          AuthComponent(
            viewState: .init(),
            tapAction: { store.send(.routeToUpdateAuth) })
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

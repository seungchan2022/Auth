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
      || store.fetchDeleteProfileImage.isLoading
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
            tapAction: {
              store.isShowSheet = true
            })
          AuthComponent(
            viewState: .init(),
            tapAction: { store.send(.routeToUpdateAuth) })
        }
      }
    }
    .sheet(isPresented: $store.isShowSheet, onDismiss: {
      if store.isShowPhotsPicker {
        store.isShowPhotsPicker = true // 시트 닫힌 후 포토 피커 띄우기
      }
    }) {
      SheetComponent(
        viewState: .init(),
        deleteTapAction: {
          store.isShowSheet = false
          store.send(.onTapDeleteProfileImage)
        },
        takePhotoTapAction: {
          store.isShowSheet = false
          store.isShowCarmera = true
        },
        selectTapAction: {
          store.isShowSheet = false
          store.isShowPhotsPicker = true
        })
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
    .fullScreenCover(isPresented: $store.isShowCarmera) {
      CarmeraComponent(store: store)
        .ignoresSafeArea()
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

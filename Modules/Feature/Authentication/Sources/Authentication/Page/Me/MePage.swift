import Architecture
import ComposableArchitecture
import DesignSystem
import SwiftUI
import PhotosUI

// MARK: - MePage

struct MePage {
  @Bindable var store: StoreOf<MeReducer>
}

extension MePage {
  private var userName: String {
    guard let userName = store.user.userName else { return "이름을 설정해주세요." }
    return userName.isEmpty ? "이름을 설정해주세요." : userName
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
          PhotosPicker(selection: $store.selectedImage) {
            VStack(alignment: .center) {
              if let profileImage = store.profileImage {
                profileImage
                  .resizable()
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
              else {
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
            }
            .foregroundStyle(.black)
          }
          .onChange(of: store.selectedImage) { _, new in
            Task {
              guard let item = new else { return }
              guard let imageData = try? await item.loadTransferable(type: Data.self) else { return }
              guard let uiImage = UIImage(data: imageData) else { return }
              store.profileImage = Image(uiImage: uiImage)
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
    .onAppear {
      store.send(.getUser)
    }
    .onDisappear {
      store.send(.teardown)
    }
  }
}

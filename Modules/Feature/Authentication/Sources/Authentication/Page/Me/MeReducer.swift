import Architecture
import ComposableArchitecture
import Domain
import Foundation
import PhotosUI
import SwiftUI

@Reducer
struct MeReducer {

  // MARK: Lifecycle

  init(
    pageID: String = UUID().uuidString,
    sideEffect: MeSideEffect)
  {
    self.pageID = pageID
    self.sideEffect = sideEffect
  }

  // MARK: Internal

  @ObservableState
  struct State: Equatable, Identifiable {
    let id: UUID

    var userCapturedImageData: Data?
    var selectedImage: PhotosPickerItem?
    var isShowSheet = false
    var isShowCarmera = false
    var isShowPhotsPicker = false

    var user: Authentication.Me.Response = .init(uid: "", userName: "", email: "", photoURL: "")
    var fetchUser: FetchState.Data<Authentication.Me.Response?> = .init(isLoading: false, value: .none)

    var fetchUpdateProfileImage: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)
    var fetchDeleteProfileImage: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)

    init(id: UUID = UUID()) {
      self.id = id
    }
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case teardown

    case getUser
    case updateProfileImage(Data)

    case onTapDeleteProfileImage

    case fetchUser(Result<Authentication.Me.Response?, CompositeErrorRepository>)

    case fetchUpdateProfileImage(Result<Bool?, CompositeErrorRepository>)
    case fetchDeleteProfileImage(Result<Bool?, CompositeErrorRepository>)

    case routeToBack
    case routeToUpdateAuth

    case throwError(CompositeErrorRepository)
  }

  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestUser
    case requestSignOut
    case requestUpdateProfileImage
    case requestDeleteProfileImage
  }

  var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CancelID.allCases.map { .cancel(pageID: pageID, id: $0) })

      case .getUser:
        state.fetchUser.isLoading = true
        return sideEffect
          .getUser()
          .cancellable(pageID: pageID, id: CancelID.requestUser, cancelInFlight: true)

      case .updateProfileImage(let imageData):
        state.fetchUpdateProfileImage.isLoading = true
        return sideEffect
          .updateProfileImage(imageData)
          .cancellable(pageID: pageID, id: CancelID.requestUpdateProfileImage, cancelInFlight: true)

      case .onTapDeleteProfileImage:
        state.fetchDeleteProfileImage.isLoading = true
        return sideEffect
          .deleteProfileImage()
          .cancellable(pageID: pageID, id: CancelID.requestDeleteProfileImage, cancelInFlight: true)

      case .fetchUser(let result):
        state.fetchUser.isLoading = false
        switch result {
        case .success(let user):
          state.user = user ?? .init(uid: "", userName: "", email: "", photoURL: "")
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .fetchUpdateProfileImage(let result):
        state.fetchUpdateProfileImage.isLoading = false
        switch result {
        case .success:
          sideEffect.routeToBack()
          sideEffect.useCase.toastViewModel.send(message: "프로필 이미지 변경")
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .fetchDeleteProfileImage(let result):
        state.fetchDeleteProfileImage.isLoading = false
        switch result {
        case .success:
          sideEffect.routeToBack()
          sideEffect.useCase.toastViewModel.send(message: "프로필 이미지를 삭제하였습니다.")
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .routeToBack:
        sideEffect.routeToBack()
        return .none

      case .routeToUpdateAuth:
        sideEffect.routeToAuth()
        return .none

      case .throwError(let error):
        sideEffect.useCase.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }

  // MARK: Private

  private let pageID: String
  private let sideEffect: MeSideEffect

}

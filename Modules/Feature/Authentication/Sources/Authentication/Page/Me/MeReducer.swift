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

    var user: Authentication.Me.Response = .init(uid: "", userName: "", email: "", photoURL: "")
    var fetchUser: FetchState.Data<Authentication.Me.Response?> = .init(isLoading: false, value: .none)

    var selectedImage: PhotosPickerItem?
    var profileImage: Image?

    init(id: UUID = UUID()) {
      self.id = id
    }
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case teardown

    case getUser

    case fetchUser(Result<Authentication.Me.Response?, CompositeErrorRepository>)

    case routeToBack
    case routeToUpdateAuth

    case throwError(CompositeErrorRepository)
  }

  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestUser
    case requestSignOut
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

      case .fetchUser(let result):
        state.fetchUser.isLoading = false
        switch result {
        case .success(let user):
          state.user = user ?? .init(uid: "", userName: "", email: "", photoURL: "")
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

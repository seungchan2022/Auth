import Architecture
import ComposableArchitecture
import Domain
import Foundation

@Reducer
struct UpdateAuthReducer {

  // MARK: Lifecycle

  init(
    pageID: String = UUID().uuidString,
    sideEffect: UpdateAuthSideEffect)
  {
    self.pageID = pageID
    self.sideEffect = sideEffect
  }

  // MARK: Internal

  @ObservableState
  struct State: Equatable, Identifiable {

    // MARK: Lifecycle

    init(id: UUID = UUID()) {
      self.id = id
    }

    // MARK: Internal

    let id: UUID

    var isShowUpdateUserNameAlert = false
    var isShowSignOutAlert = false
    var isShowDeleteUserAlert = false

    var updateUserName = ""

    var passwordText = ""

    var user: Authentication.Me.Response = .init(uid: "", userName: "", email: "", photoURL: "")

    var fetchUser: FetchState.Data<Authentication.Me.Response?> = .init(isLoading: false, value: .none)
    var fetchSignOut: FetchState.Data<Bool> = .init(isLoading: false, value: false)
    var fetchUpdateUserName: FetchState.Data<Bool> = .init(isLoading: false, value: false)
    var fetchDeleteUser: FetchState.Data<Bool> = .init(isLoading: false, value: false)

  }

  enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case teardown

    case getUser

    case onTapSignOut
    case onTapUpdateUserName
    case onTapDeleteUser

    case fetchUser(Result<Authentication.Me.Response?, CompositeErrorRepository>)
    case fetchSignOut(Result<Bool, CompositeErrorRepository>)
    case fetchUpdateUserName(Result<Bool, CompositeErrorRepository>)
    case fetchDeleteUser(Result<Bool, CompositeErrorRepository>)

    case routeToUpdatePassword
    case routeToBack

    case throwError(CompositeErrorRepository)
  }

  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestUser
    case requestSignOut
    case requestUpdateUserName
    case requestDeleteUser
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
          .user()
          .cancellable(pageID: pageID, id: CancelID.requestUser, cancelInFlight: true)

      case .onTapSignOut:
        state.fetchSignOut.isLoading = true
        return sideEffect
          .signOut()
          .cancellable(pageID: pageID, id: CancelID.requestSignOut, cancelInFlight: true)

      case .onTapUpdateUserName:
        return sideEffect
          .updateUserName(state.updateUserName)
          .cancellable(pageID: pageID, id: CancelID.requestUpdateUserName, cancelInFlight: true)

      case .onTapDeleteUser:
        return sideEffect
          .deleteUser(state.passwordText)
          .cancellable(pageID: pageID, id: CancelID.requestDeleteUser, cancelInFlight: true)

      case .fetchUser(let result):
        state.fetchUser.isLoading = false
        switch result {
        case .success(let user):
          state.user = user ?? .init(uid: "", userName: "", email: "", photoURL: "")
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .fetchSignOut(let result):
        state.fetchSignOut.isLoading = false
        switch result {
        case .success:
          sideEffect.routeToSignIn()
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .fetchUpdateUserName(let result):
        state.fetchUpdateUserName.isLoading = false
        switch result {
        case .success:
          return .run { await $0(.getUser) }

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .fetchDeleteUser(let result):
        state.fetchDeleteUser.isLoading = false
        switch result {
        case .success:
          sideEffect.useCase.toastViewModel.send(message: "계정이 탈퇴되었습니다.")
          sideEffect.routeToSignIn()
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .routeToUpdatePassword:
        sideEffect.routeToUpdatePassword()
        return .none

      case .routeToBack:
        sideEffect.routeToBack()
        return .none

      case .throwError(let error):
        sideEffect.useCase.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }

  // MARK: Private

  private let pageID: String
  private let sideEffect: UpdateAuthSideEffect
}

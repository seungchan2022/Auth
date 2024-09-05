import Architecture
import ComposableArchitecture
import Domain
import Foundation

@Reducer
struct SignInReducer {

  // MARK: Lifecycle

  init(
    pageID: String = UUID().uuidString,
    sideEffect: SignInSideEffect)
  {
    self.pageID = pageID
    self.sideEffect = sideEffect
  }

  // MARK: Internal

  @ObservableState
  struct State: Equatable, Identifiable {
    let id: UUID

    var emailText = ""
    var passwordText = ""

    var resetEmailText = ""

    var isShowPassword = false

    var isShowResetPassword = false

    init(id: UUID = UUID()) {
      self.id = id
    }
  }

  enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case teardown

    case routeToSignUp

    case throwError(CompositeErrorRepository)
  }

  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestSignIn
  }

  var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { _, action in
      switch action {
      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CancelID.allCases.map { .cancel(pageID: pageID, id: $0) })

      case .routeToSignUp:
        sideEffect.routeToSignUp()
        return .none

      case .throwError(let error):
        sideEffect.useCase.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }

  // MARK: Private

  private let pageID: String
  private let sideEffect: SignInSideEffect
}

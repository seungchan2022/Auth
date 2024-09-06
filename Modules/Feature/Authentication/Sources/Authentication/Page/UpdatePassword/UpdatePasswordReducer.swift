import Architecture
import ComposableArchitecture
import Domain
import Foundation

@Reducer
struct UpdatePasswordReducer {

  // MARK: Lifecycle

  init(
    pageID: String = UUID().uuidString,
    sideEffect: UpdatePasswordSideEffect)
  {
    self.pageID = pageID
    self.sideEffect = sideEffect
  }

  // MARK: Internal

  @ObservableState
  struct State: Equatable, Identifiable {
    let id: UUID

    var currPasswordText = ""
    var newPasswordText = ""
    var confirmPasswordText = ""

    var isValidPassword = true
    var isValidConfirmPassword = true

    var isShowCurrPassword = false
    var isShowNewPassword = false
    var isShowConfirmPassword = false

    var fetchUpdatePassword: FetchState.Data<Bool> = .init(isLoading: false, value: false)

    init(id: UUID = UUID()) {
      self.id = id
    }
  }

  enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case teardown

    case onTapUpdatePassword

    case fetchUpdatePassword(Result<Bool, CompositeErrorRepository>)

    case routeToClose

    case throwError(CompositeErrorRepository)
  }

  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestUpdatePassword
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

      case .onTapUpdatePassword:
        if state.currPasswordText == state.newPasswordText {
          sideEffect.useCase.toastViewModel.send(errorMessage: "현재 비밀번호와 다르게 설정해주세요")
          state.fetchUpdatePassword.isLoading = false
          return .none
        }

        state.fetchUpdatePassword.isLoading = true
        return sideEffect
          .updatePassword(state.currPasswordText, state.newPasswordText)
          .cancellable(pageID: pageID, id: CancelID.requestUpdatePassword, cancelInFlight: true)

      case .fetchUpdatePassword(let result):
        state.fetchUpdatePassword.isLoading = false
        switch result {
        case .success:
          sideEffect.useCase.toastViewModel.send(message: "비밀번호 변경이 완료되었습니다.")
          sideEffect.routeToClose()
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .routeToClose:
        sideEffect.routeToClose()
        return .none

      case .throwError(let error):
        sideEffect.useCase.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }

  // MARK: Private

  private let pageID: String
  private let sideEffect: UpdatePasswordSideEffect
}

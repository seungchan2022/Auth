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

    var fetchSignIn: FetchState.Data<Bool> = .init(isLoading: false, value: false)
    var fetchResetPassword: FetchState.Data<Bool> = .init(isLoading: false, value: false)
    var fetchGoogleSignIn: FetchState.Data<Bool> = .init(isLoading: false, value: false)

    init(id: UUID = UUID()) {
      self.id = id
    }
  }

  enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case teardown

    case onTapSignIn
    case onTapResetPassword
    case onTapGoogleSignIn

    case fetchSignIn(Result<Bool, CompositeErrorRepository>)
    case fetchResetPassword(Result<Bool, CompositeErrorRepository>)
    case fetchGoogleSignIn(Result<Bool, CompositeErrorRepository>)

    case routeToBack
    case routeToSignUp

    case routeToMe

    case throwError(CompositeErrorRepository)
  }

  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestSignIn
    case requestResetPassword
    case requestGoogleSignIn
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

      case .onTapSignIn:
        state.fetchSignIn.isLoading = true
        return sideEffect
          .signIn(.init(email: state.emailText, password: state.passwordText))
          .cancellable(pageID: pageID, id: CancelID.requestSignIn, cancelInFlight: true)

      case .onTapResetPassword:
        state.fetchResetPassword.isLoading = true
        return sideEffect
          .resetPassword(state.resetEmailText)
          .cancellable(pageID: pageID, id: CancelID.requestResetPassword, cancelInFlight: true)

      case .onTapGoogleSignIn:
        state.fetchGoogleSignIn.isLoading = true
        return sideEffect
          .googleSignIn()
          .cancellable(pageID: pageID, id: CancelID.requestGoogleSignIn, cancelInFlight: true)

      case .fetchSignIn(let result):
        state.fetchSignIn.isLoading = false
        switch result {
        case .success:
          sideEffect.routeToMe()
          return .none

        case .failure:
          sideEffect.useCase.toastViewModel.send(message: "이메일 혹은 비밀번호가 잘못되었습니다.")
          return .none
        }

      case .fetchResetPassword(let result):
        state.fetchResetPassword.isLoading = false
        switch result {
        case .success:
          sideEffect.useCase.toastViewModel.send(message: "입력하신 이메일 주소로 비밀번호 재설정 링크가 전송되었습니다.")
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .fetchGoogleSignIn(let result):
        state.fetchGoogleSignIn.isLoading = false
        switch result {
        case .success:
          sideEffect.routeToMe()
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .routeToBack:
        sideEffect.routeToBack()
        return .none

      case .routeToSignUp:
        sideEffect.routeToSignUp()
        return .none

      case .routeToMe:
        sideEffect.routeToMe()
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

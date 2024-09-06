import Architecture
import Combine
import CombineExt
import ComposableArchitecture
import Domain
import Foundation

// MARK: - SignInSideEffect

struct SignInSideEffect {
  let useCase: AuthenticationEnvironmentUsable
  let main: AnySchedulerOf<DispatchQueue>
  let navigator: RootNavigatorType

  init(
    useCase: AuthenticationEnvironmentUsable,
    main: AnySchedulerOf<DispatchQueue> = .main,
    navigator: RootNavigatorType)
  {
    self.useCase = useCase
    self.main = main
    self.navigator = navigator
  }
}

extension SignInSideEffect {
  var signIn: (Authentication.Email.Request) -> Effect<SignInReducer.Action> {
    { req in
      .publisher {
        useCase.authenticationUseCase
          .signInEmail(req)
          .map { _ in true }
          .mapToResult()
          .map(SignInReducer.Action.fetchSignIn)
      }
    }
  }

  var resetPassword: (String) -> Effect<SignInReducer.Action> {
    { email in
      .publisher {
        useCase.authenticationUseCase
          .resetPassword(email)
          .map { _ in true }
          .receive(on: main)
          .mapToResult()
          .map(SignInReducer.Action.fetchResetPassword)
      }
    }
  }

  var routeToSignUp: () -> Void {
    {
      navigator.next(
        linkItem: .init(path: Link.Authentication.Path.signUp.rawValue),
        isAnimated: true)
    }
  }

  var routeToMe: () -> Void {
    {
      navigator.next(
        linkItem: .init(path: Link.Authentication.Path.me.rawValue),
        isAnimated: true)
    }
  }
}

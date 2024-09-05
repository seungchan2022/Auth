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

  var routeToSignUp: () -> Void {
    {
      navigator.next(
        linkItem: .init(path: Link.Authentication.Path.signUp.rawValue),
        isAnimated: true)
    }
  }

  var routeToHome: () -> Void {
    {
      navigator.next(
        linkItem: .init(path: Link.Authentication.Path.home.rawValue),
        isAnimated: true)
    }
  }
}

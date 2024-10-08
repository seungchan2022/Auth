import Architecture
import Combine
import CombineExt
import ComposableArchitecture
import Domain
import Foundation

// MARK: - SignInSideEffect

struct SignInSideEffect {
  let useCase: DashboardEnvironmentUsable
  let main: AnySchedulerOf<DispatchQueue>
  let navigator: RootNavigatorType

  init(
    useCase: DashboardEnvironmentUsable,
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
          .receive(on: main)
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

  var googleSignIn: () -> Effect<SignInReducer.Action> {
    {
      .publisher {
        useCase.authenticationUseCase
          .signInGoogle()
          .map { _ in true }
          .receive(on: main)
          .mapToResult()
          .map(SignInReducer.Action.fetchGoogleSignIn)
      }
    }
  }

  var routeToBack: () -> Void {
    {
      navigator.back(isAnimated: true)
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
        linkItem: .init(path: Link.Dashboard.Path.home.rawValue),
        isAnimated: true)
    }
  }
}

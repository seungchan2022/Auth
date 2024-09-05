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
  var routeToSignUp: () -> Void {
    {
      navigator.next(
        linkItem: .init(path: Link.Authentication.Path.signUp.rawValue),
        isAnimated: true)
    }
  }
}

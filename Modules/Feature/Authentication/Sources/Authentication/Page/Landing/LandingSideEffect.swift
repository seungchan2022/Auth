import Architecture
import ComposableArchitecture
import Foundation

// MARK: - LandingSideEffect

struct LandingSideEffect {
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

extension LandingSideEffect {
  var routeToSignIn: () -> Void {
    {
      navigator.next(
        linkItem: .init(path: Link.Authentication.Path.signIn.rawValue),
        isAnimated: true)
    }
  }

  var routeToSignUp: () -> Void {
    {
      navigator.next(
        linkItem: .init(path: Link.Authentication.Path.signUp.rawValue),
        isAnimated: true)
    }
  }
}

import Architecture
import Combine
import CombineExt
import ComposableArchitecture
import Domain
import Foundation

// MARK: - SignUpSideEffect

struct SignUpSideEffect {
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

extension SignUpSideEffect {
  var routeToSignIn: () -> Void {
    {
      navigator.back(isAnimated: true)
    }
  }
}

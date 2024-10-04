import Architecture
import Combine
import ComposableArchitecture
import Foundation

// MARK: - HomeSideEffect

struct HomeSideEffect {
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

extension HomeSideEffect {
  var routeToMe: () -> Void {
    {
      navigator.next(
        linkItem: .init(path: Link.Authentication.Path.me.rawValue),
        isAnimated: true)
    }
  }
}

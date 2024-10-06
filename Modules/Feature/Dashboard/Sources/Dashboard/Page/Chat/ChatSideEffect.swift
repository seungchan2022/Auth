import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - ChatSideEffect

struct ChatSideEffect {
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

extension ChatSideEffect {
  var routeToBack: () -> Void {
    {
      navigator.back(isAnimated: true)
    }
  }
}

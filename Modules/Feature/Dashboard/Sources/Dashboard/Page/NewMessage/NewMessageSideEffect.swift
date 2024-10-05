import Architecture
import ComposableArchitecture
import Foundation

// MARK: - NewMessageSideEffect

struct NewMessageSideEffect {
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

extension NewMessageSideEffect {
  var routeToClose: () -> Void {
    {
      navigator.close(isAnimated: true, completeAction: { })
    }
  }
}

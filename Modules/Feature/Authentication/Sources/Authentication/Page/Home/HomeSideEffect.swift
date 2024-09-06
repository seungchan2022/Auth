import Architecture
import Combine
import CombineExt
import ComposableArchitecture
import Domain
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
  var getUser: () -> Effect<HomeReducer.Action> {
    {
      .publisher {
        useCase.authenticationUseCase
          .me()
          .receive(on: main)
          .mapToResult()
          .map(HomeReducer.Action.fetchUser)
      }
    }
  }
}

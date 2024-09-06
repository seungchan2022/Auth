import Architecture
import Combine
import CombineExt
import ComposableArchitecture
import Domain
import Foundation

// MARK: - MeSideEffect

struct MeSideEffect {
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

extension MeSideEffect {
  var getUser: () -> Effect<MeReducer.Action> {
    {
      .publisher {
        useCase.authenticationUseCase
          .me()
          .receive(on: main)
          .mapToResult()
          .map(MeReducer.Action.fetchUser)
      }
    }
  }
}

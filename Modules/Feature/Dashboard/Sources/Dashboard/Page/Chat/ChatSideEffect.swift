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
  var getUserInfo: (Authentication.Me.Response) -> Effect<ChatReducer.Action> {
    { user in
      .publisher {
        useCase.chatUseCase
          .getUser(user.uid)
          .receive(on: main)
          .mapToResult()
          .map(ChatReducer.Action.fetchUserInfo)
      }
    }
  }

  var routeToBack: () -> Void {
    {
      navigator.back(isAnimated: true)
    }
  }
}

import Architecture
import Combine
import CombineExt
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
  var getUserList: () -> Effect<NewMessageReducer.Action> {
    {
      .publisher {
        useCase.chatUseCase
          .userItemList()
          .receive(on: main)
          .mapToResult()
          .map(NewMessageReducer.Action.fetchUserList)
      }
    }
  }

  var routeToClose: () -> Void {
    {
      navigator.close(isAnimated: true, completeAction: { })
    }
  }

  var routeToChat: () -> Void {
    {
      navigator.next(
        linkItem: .init(path: Link.Dashboard.Path.chat.rawValue),
        isAnimated: true)
    }
  }
}

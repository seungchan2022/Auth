import Architecture
import Combine
import CombineExt
import ComposableArchitecture
import Foundation

// MARK: - HomeSideEffect

struct HomeSideEffect {
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

extension HomeSideEffect {
  var getUserList: () -> Effect<HomeReducer.Action> {
    {
      .publisher {
        useCase.chatUseCase
          .userItemList()
          .receive(on: main)
          .mapToResult()
          .map(HomeReducer.Action.fetchUserList)
      }
    }
  }

  var routeToMe: () -> Void {
    {
      navigator.next(
        linkItem: .init(path: Link.Authentication.Path.me.rawValue),
        isAnimated: true)
    }
  }

  var routeToNewMessage: () -> Void {
    {
      navigator.fullSheet(
        linkItem: .init(path: Link.Dashboard.Path.newMessage.rawValue),
        isAnimated: true,
        prefersLargeTitles: false)
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

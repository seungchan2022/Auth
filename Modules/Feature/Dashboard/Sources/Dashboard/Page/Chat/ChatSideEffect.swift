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

  var sendMessage: (String, String) -> Effect<ChatReducer.Action> {
    { chatPartner, text in
      .publisher {
        useCase.chatUseCase
          .sendMessage(chatPartner, text)
          .receive(on: main)
          .mapToResult()
          .map(ChatReducer.Action.fetchSendMessage)
      }
    }
  }

  var sendImageMessage: (String, Data) -> Effect<ChatReducer.Action> {
    { chatPartner, imageData in
      .publisher {
        useCase.chatUseCase
          .sendImageMessage(chatPartner, imageData)
          .receive(on: main)
          .mapToResult()
          .map(ChatReducer.Action.fetchSendImageMessage)
      }
    }
  }

  var getItemList: (Authentication.Me.Response) -> Effect<ChatReducer.Action> {
    { chatPartner in
      .publisher {
        useCase.chatUseCase
          .getMessage(chatPartner)
          .receive(on: main)
          .mapToResult()
          .map(ChatReducer.Action.fetchItemList)
      }
    }
  }

  var routeToBack: () -> Void {
    {
      navigator.back(isAnimated: true)
    }
  }
}

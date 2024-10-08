import Architecture
import ComposableArchitecture
import Domain
import Foundation

@Reducer
struct ChatReducer {

  // MARK: Lifecycle

  init(
    pageID: String = UUID().uuidString,
    sideEffect: ChatSideEffect)
  {
    self.pageID = pageID
    self.sideEffect = sideEffect
  }

  // MARK: Internal

  @ObservableState
  struct State: Equatable, Identifiable {
    let id: UUID

    let userInfo: Authentication.Me.Response

    var messageText = ""

    var fetchSendMessage: FetchState.Data<Chat.Message.Item?> = .init(isLoading: false, value: .none)

    var fetchUserInfo: FetchState.Data<Authentication.Me.Response?> = .init(isLoading: false, value: .none)

    init(
      id: UUID = UUID(),
      userInfo: Authentication.Me.Response)
    {
      self.id = id
      self.userInfo = userInfo
    }
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case teardown

    case getUserInfo(Authentication.Me.Response)

    case onTapSendMessage(String)
    case fetchSendMessage(Result<Chat.Message.Item, CompositeErrorRepository>)

    case fetchUserInfo(Result<Authentication.Me.Response, CompositeErrorRepository>)

    case routeToBack

    case throwError(CompositeErrorRepository)
  }

  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestUserInfo
    case requestSendMessage
  }

  var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CancelID.allCases.map { .cancel(pageID: pageID, id: $0) })

      case .getUserInfo(let user):
        state.fetchUserInfo.isLoading = true
        return sideEffect
          .getUserInfo(user)
          .cancellable(pageID: pageID, id: CancelID.requestUserInfo, cancelInFlight: true)

      case .onTapSendMessage(let text):
        state.fetchSendMessage.isLoading = true
        return sideEffect
          .sendMessage(state.userInfo.uid, text)
          .cancellable(pageID: pageID, id: CancelID.requestSendMessage, cancelInFlight: true)

      case .fetchSendMessage(let result):
        state.fetchSendMessage.isLoading = false
        switch result {
        case .success(let item):
          state.messageText = item.messageText
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .fetchUserInfo(let result):
        state.fetchUserInfo.isLoading = false
        switch result {
        case .success(let user):
          state.fetchUserInfo.value = user
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .routeToBack:
        sideEffect.routeToBack()
        return .none

      case .throwError(let error):
        sideEffect.useCase.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }

  // MARK: Private

  private let pageID: String
  private let sideEffect: ChatSideEffect

}

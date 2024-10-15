import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - HomeReducer

@Reducer
struct HomeReducer {

  // MARK: Lifecycle

  init(
    pageID: String = UUID().uuidString,
    sideEffect: HomeSideEffect)
  {
    self.pageID = pageID
    self.sideEffect = sideEffect
  }

  // MARK: Internal

  @ObservableState
  struct State: Identifiable {
    let id: UUID

    var userList: [Authentication.Me.Response] = []
    var fetchUserList: FetchState.Data<[Authentication.Me.Response]?> = .init(isLoading: false, value: .none)

    var recentMessageList: [Chat.Message.Item] = []
    var fetchRecentMessageList: FetchState.Data<[Chat.Message.Item]?> = .init(isLoading: false, value: .none)

    init(id: UUID = UUID()) {
      self.id = id
    }
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case teardown

    case getUserList
    case fetchUserList(Result<[Authentication.Me.Response], CompositeErrorRepository>)

    case getRecentMessageList
    case fetchRecentMessageList(Result<[Chat.Message.Item], CompositeErrorRepository>)

    case routeToMe
    case routeToNewMessage
    case routeToChat(Authentication.Me.Response)

    case throwError(CompositeErrorRepository)
  }

  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestUserList
    case requestRecentMessageList
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

      case .getUserList:
        state.fetchUserList.isLoading = true
        return sideEffect
          .getUserList()
          .cancellable(pageID: pageID, id: CancelID.requestUserList, cancelInFlight: true)

      case .fetchUserList(let result):
        state.fetchUserList.isLoading = false
        switch result {
        case .success(let itemList):
          state.userList = itemList
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .getRecentMessageList:
        state.fetchRecentMessageList.isLoading = true
        return sideEffect
          .getRecentMessageList()
          .cancellable(pageID: pageID, id: CancelID.requestRecentMessageList, cancelInFlight: true)

      case .fetchRecentMessageList(let result):
        state.fetchRecentMessageList.isLoading = false
        switch result {
        case .success(let itemList):
          state.fetchRecentMessageList.value = itemList
          state.recentMessageList = state.recentMessageList.merge(itemList)
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .routeToMe:
        sideEffect.routeToMe()
        return .none

      case .routeToNewMessage:
        sideEffect.routeToNewMessage()
        return .none

      case .routeToChat(let item):
        sideEffect.routeToChat(item)
        return .none

      case .throwError(let error):
        sideEffect.useCase.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }

  // MARK: Private

  private let pageID: String
  private let sideEffect: HomeSideEffect

}

extension [Chat.Message.Item] {
  /// 중복된게 올라옴
  fileprivate func merge(_ target: Self) -> Self {
    let new = target.reduce(self) { curr, next in
      guard !self.contains(where: { $0.id == next.id }) else { return curr }
      return curr + [next]
    }

    return new
  }
}

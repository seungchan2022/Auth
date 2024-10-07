import Architecture
import ComposableArchitecture
import Domain
import Foundation

@Reducer
struct NewMessageReducer {

  // MARK: Lifecycle

  init(
    pageID: String = UUID().uuidString,
    sideEffect: NewMessageSideEffect)
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

    init(id: UUID = UUID()) {
      self.id = id
    }
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case teardown

    case getUserList
    case fetchUserList(Result<[Authentication.Me.Response], CompositeErrorRepository>)

    case routeToClose
    case routeToChat(Authentication.Me.Response)

    case throwError(CompositeErrorRepository)
  }

  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestUserList
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

      case .routeToClose:
        sideEffect.routeToClose()
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
  private let sideEffect: NewMessageSideEffect

}

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

    init(id: UUID = UUID()) {
      self.id = id
    }
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case teardown

    case routeToBack

    case throwError(CompositeErrorRepository)
  }

  enum CancelID: Equatable, CaseIterable {
    case teardown
  }

  var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { _, action in
      switch action {
      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CancelID.allCases.map { .cancel(pageID: pageID, id: $0) })

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

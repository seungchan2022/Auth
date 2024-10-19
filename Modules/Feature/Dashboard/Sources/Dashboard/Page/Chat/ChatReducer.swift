import Architecture
import ComposableArchitecture
import Domain
import Foundation
import PhotosUI
import SwiftUI

// MARK: - ChatReducer

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

    // MARK: Lifecycle

    init(
      id: UUID = UUID(),
      userInfo: Authentication.Me.Response)
    {
      self.id = id
      self.userInfo = userInfo
    }

    // MARK: Internal

    let id: UUID

    var selectedImage: PhotosPickerItem?
    var isShowPhotosPicker = false

    let userInfo: Authentication.Me.Response

    var messageText = ""

    var itemList: [Chat.Message.Item] = []

    var fetchSendMessage: FetchState.Data<Chat.Message.Item?> = .init(isLoading: false, value: .none)

    var fetchSendImageMessage: FetchState.Data<Chat.Message.Item?> = .init(isLoading: false, value: .none)

    var fetchItemList: FetchState.Data<[Chat.Message.Item]?> = .init(isLoading: false, value: .none)

    var fetchUserInfo: FetchState.Data<Authentication.Me.Response?> = .init(isLoading: false, value: .none)

  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case teardown

    case getUserInfo(Authentication.Me.Response)

    case onTapSendMessage(String)
    case fetchSendMessage(Result<Chat.Message.Item, CompositeErrorRepository>)

    case sendImageMessage(Data)
    case fetchSendImageMessage(Result<Chat.Message.Item, CompositeErrorRepository>)

    case getItemList
    case fetchItemList(Result<[Chat.Message.Item], CompositeErrorRepository>)

    case fetchUserInfo(Result<Authentication.Me.Response, CompositeErrorRepository>)

    case routeToBack

    case throwError(CompositeErrorRepository)
  }

  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestUserInfo
    case requestSendMessage
    case requestItemList
    case requestSendImageMessage
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

      case .getItemList:
        return sideEffect
          .getItemList(state.userInfo)
          .cancellable(pageID: pageID, id: CancelID.requestItemList, cancelInFlight: true)

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

      case .sendImageMessage(let imageData):
        state.fetchSendImageMessage.isLoading = true
        return sideEffect
          .sendImageMessage(state.userInfo.uid, imageData)
          .cancellable(pageID: pageID, id: CancelID.requestSendImageMessage, cancelInFlight: true)

      case .fetchSendImageMessage(let result):
        state.fetchSendImageMessage.isLoading = false
        switch result {
        case .success(let item):
          state.fetchSendImageMessage.value = item
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .fetchSendMessage(let result):
        state.fetchSendMessage.isLoading = false
        switch result {
        case .success(let item):
          state.fetchSendMessage.value = item
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .fetchItemList(let result):
        switch result {
        case .success(let itemList):
          state.fetchItemList.value = itemList
          state.itemList = state.itemList.merge(itemList)
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

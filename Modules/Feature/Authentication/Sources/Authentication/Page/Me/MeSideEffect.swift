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

  var updateProfileImage: (Data) -> Effect<MeReducer.Action> {
    { imageData in
      .publisher {
        useCase.authenticationUseCase
          .updateProfileImage(imageData)
          .map { _ in true }
          .receive(on: main)
          .mapToResult()
          .map(MeReducer.Action.fetchUpdateProfileImage)
      }
    }
  }

  var deleteProfileImage: () -> Effect<MeReducer.Action> {
    {
      .publisher {
        useCase.authenticationUseCase
          .deleteUserProfileImage()
          .map { _ in true }
          .receive(on: main)
          .mapToResult()
          .map(MeReducer.Action.fetchDeleteProfileImage)
      }
    }
  }

  var routeToBack: () -> Void {
    {
      navigator.back(isAnimated: true)
    }
  }

  var routeToAuth: () -> Void {
    {
      navigator.next(
        linkItem: .init(path: Link.Authentication.Path.updateAuth.rawValue),
        isAnimated: true)
    }
  }
}

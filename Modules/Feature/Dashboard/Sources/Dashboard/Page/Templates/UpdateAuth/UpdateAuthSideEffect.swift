import Architecture
import ComposableArchitecture
import Foundation

// MARK: - UpdateAuthSideEffect

struct UpdateAuthSideEffect {
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

extension UpdateAuthSideEffect {
  var user: () -> Effect<UpdateAuthReducer.Action> {
    {
      .publisher {
        useCase.authenticationUseCase
          .me()
          .receive(on: main)
          .mapToResult()
          .map(UpdateAuthReducer.Action.fetchUser)
      }
    }
  }

  var signOut: () -> Effect<UpdateAuthReducer.Action> {
    {
      .publisher {
        useCase.authenticationUseCase.signOut()
          .map { _ in true }
          .receive(on: main)
          .mapToResult()
          .map(UpdateAuthReducer.Action.fetchSignOut)
      }
    }
  }

  var updateUserName: (String) -> Effect<UpdateAuthReducer.Action> {
    { newName in
      .publisher {
        useCase.authenticationUseCase
          .updateUserName(newName)
          .map { _ in true }
          .receive(on: main)
          .mapToResult()
          .map(UpdateAuthReducer.Action.fetchUpdateUserName)
      }
    }
  }

  var deleteUser: (String) -> Effect<UpdateAuthReducer.Action> {
    { currPassword in
      .publisher {
        useCase.authenticationUseCase
          .deleteUser(currPassword)
          .map { _ in true }
          .receive(on: main)
          .mapToResult()
          .map(UpdateAuthReducer.Action.fetchDeleteUser)
      }
    }
  }

  var routeToSignIn: () -> Void {
    {
      navigator.replace(
        linkItem: .init(pathList: [
          Link.Authentication.Path.landing.rawValue,
          Link.Authentication.Path.signIn.rawValue,
        ]),
        isAnimated: false)
    }
  }

  var routeToUpdatePassword: () -> Void {
    {
      navigator.fullSheet(
        linkItem: .init(path: Link.Authentication.Path.updatePassword.rawValue),
        isAnimated: true,
        prefersLargeTitles: false)
    }
  }

  var routeToBack: () -> Void {
    {
      navigator.back(isAnimated: true)
    }
  }
}

import Architecture
import Domain
import LinkNavigator

struct ChatRouteBuilder<RootNavigator: RootNavigatorType> {
  static func generate() -> RouteBuilderOf<RootNavigator> {
    let matchPath = Link.Dashboard.Path.chat.rawValue

    return .init(matchPath: matchPath) { navigator, items, diContainer -> RouteViewController? in
      guard let env: DashboardEnvironmentUsable = diContainer.resolve() else { return .none }
      guard let items: Authentication.Me.Response = items.decoded() else { return .none }

      return DebugWrappingController(matchPath: matchPath) {
        ChatPage(
          store: .init(
            initialState: ChatReducer.State(userInfo: items),
            reducer: {
              ChatReducer(
                sideEffect: .init(
                  useCase: env,
                  navigator: navigator))
            }))
      }
    }
  }
}

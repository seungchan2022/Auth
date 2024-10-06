import Architecture
import LinkNavigator

struct ChatRouteBuilder<RootNavigator: RootNavigatorType> {
  static func generate() -> RouteBuilderOf<RootNavigator> {
    let matchPath = Link.Dashboard.Path.chat.rawValue

    return .init(matchPath: matchPath) { navigator, _, diContainer -> RouteViewController? in
      guard let env: DashboardEnvironmentUsable = diContainer.resolve() else { return .none }

      return DebugWrappingController(matchPath: matchPath) {
        ChatPage(
          store: .init(
            initialState: ChatReducer.State(),
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

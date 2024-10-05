import Architecture
import LinkNavigator

struct NewMessageRouteBuilder<RootNavigator: RootNavigatorType> {
  static func generate() -> RouteBuilderOf<RootNavigator> {
    let matchPath = Link.Dashboard.Path.newMessage.rawValue

    return .init(matchPath: matchPath) { navigator, _, diContainer -> RouteViewController? in
      guard let env: DashboardEnvironmentUsable = diContainer.resolve() else { return .none }

      return DebugWrappingController(matchPath: matchPath) {
        NewMessagePage(
          store: .init(
            initialState: NewMessageReducer.State(),
            reducer: {
              NewMessageReducer(
                sideEffect: .init(
                  useCase: env,
                  navigator: navigator))
            }))
      }
    }
  }
}

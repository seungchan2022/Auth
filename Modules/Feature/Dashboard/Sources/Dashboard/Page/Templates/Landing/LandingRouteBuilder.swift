import Architecture
import LinkNavigator

struct LandingRouteBuilder<RootNaviagtor: RootNavigatorType> {
  static func generate() -> RouteBuilderOf<RootNaviagtor> {
    let matchPath = Link.Authentication.Path.landing.rawValue

    return .init(matchPath: matchPath) { navigator, _, diContainer -> RouteViewController? in
      guard let env: DashboardEnvironmentUsable = diContainer.resolve() else { return .none }

      return DebugWrappingController(matchPath: matchPath) {
        LandingPage(
          store: .init(
            initialState: LandingReducer.State(),
            reducer: {
              LandingReducer(
                sideEffect: .init(
                  useCase: env,
                  navigator: navigator))
            }))
      }
    }
  }
}

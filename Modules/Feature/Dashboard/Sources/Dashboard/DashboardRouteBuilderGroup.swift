import Architecture
import LinkNavigator

// MARK: - DashboardRouteBuilderGroup

public struct DashboardRouteBuilderGroup<RootNavigator: RootNavigatorType> {
  public init() { }
}

extension DashboardRouteBuilderGroup {
  public static var release: [RouteBuilderOf<RootNavigator>] {
    [
      HomeRouteBuiilder.generate(),
      NewMessageRouteBuilder.generate(),
    ]
  }

  public static var templates: [RouteBuilderOf<RootNavigator>] {
    [
      LandingRouteBuilder.generate(),
      MeRouteBuilder.generate(),
      SignInRouteBuilder.generate(),
      SignUpRouteBuilder.generate(),
      UpdateAuthRouteBuilder.generate(),
      UpdatePasswordRouteBuilder.generate(),
    ]
  }
}

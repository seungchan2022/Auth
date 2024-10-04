import Architecture
import LinkNavigator

// MARK: - AuthenticationRouteBuilderGroup

public struct AuthenticationRouteBuilderGroup<RootNavigator: RootNavigatorType> {
  public init() { }
}

extension AuthenticationRouteBuilderGroup {
  public static var release: [RouteBuilderOf<RootNavigator>] {
    [
      LandingRouteBuilder.generate(),
      MeRouteBuilder.generate(),
      SignInRouteBuilder.generate(),
      SignUpRouteBuilder.generate(),
      UpdateAuthRouteBuilder.generate(),
      UpdatePasswordRouteBuilder.generate(),
    ]
  }

  public static var templates: [RouteBuilderOf<RootNavigator>] {
    [
      HomeRouteBuiilder.generate(),
    ]
  }
}

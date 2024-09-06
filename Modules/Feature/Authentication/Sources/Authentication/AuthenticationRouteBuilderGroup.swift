import Architecture
import LinkNavigator

// MARK: - AuthenticationRouteBuilderGroup

public struct AuthenticationRouteBuilderGroup<RootNavigator: RootNavigatorType> {
  public init() { }
}

extension AuthenticationRouteBuilderGroup {
  public static var release: [RouteBuilderOf<RootNavigator>] {
    [
      MeRouteBuilder.generate(),
      SignInRouteBuilder.generate(),
      SignUpRouteBuilder.generate(),
      UpdateAuthRouteBuilder.generate(),
    ]
  }
}

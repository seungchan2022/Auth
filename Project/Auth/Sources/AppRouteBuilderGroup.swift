import Architecture
import Authentication
import Dashboard
import Foundation
import LinkNavigator

struct AppRouteBuilderGroup<RootNavigator: RootNavigatorType> {

  var release: [RouteBuilderOf<RootNavigator>] {
    AuthenticationRouteBuilderGroup.release
      + DashboardRouteBuilderGroup.release
  }
}

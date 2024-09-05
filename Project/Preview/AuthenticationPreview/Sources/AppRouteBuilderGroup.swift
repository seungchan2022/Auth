import Architecture
import Authentication
import Foundation
import LinkNavigator

struct AppRouteBuilderGroup<RootNavigator: RootNavigatorType> {

  var release: [RouteBuilderOf<RootNavigator>] {
    AuthenticationRouteBuilderGroup.release
  }
}

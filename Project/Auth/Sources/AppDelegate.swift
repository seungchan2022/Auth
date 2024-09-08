import FirebaseCore
import LinkNavigator
import Platform
import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

  let container: AppContainer = .build()
  let thirdPartyContainer: ThirdPartyContainer = .init()

  var dependency: AppSideEffect { container.dependency }
  var navigator: SingleLinkNavigator { container.navigator }

  func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    thirdPartyContainer.connect()
    return true
  }

  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    thirdPartyContainer.perform(url: url)
  }

  func application(
    _: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options _: UIScene.ConnectionOptions)
    -> UISceneConfiguration
  {
    let sceneConfig = UISceneConfiguration(name: .none, sessionRole: connectingSceneSession.role)
    sceneConfig.delegateClass = SceneDelegate.self
    return sceneConfig
  }
}

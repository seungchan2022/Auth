import Architecture
import FirebaseAuth
import LinkNavigator
import SwiftUI

// MARK: - AppMain

struct AppMain {
  let viewModel: AppViewModel
}

// MARK: View

extension AppMain: View {

  var body: some View {
    LinkNavigationView(
      linkNavigator: viewModel.linkNavigator,
      item: .init(
        path: Auth.auth().currentUser != .none
          ? Link.Dashboard.Path.home.rawValue
          : Link.Authentication.Path.landing.rawValue))
      .ignoresSafeArea()
  }
}

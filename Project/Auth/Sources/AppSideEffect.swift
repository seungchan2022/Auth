import Architecture
import Authentication
import Domain
import Foundation
import LinkNavigator
import Platform

// MARK: - AppSideEffect

struct AppSideEffect: DependencyType, AuthenticationEnvironmentUsable {
  let toastViewModel: ToastViewActionType
}

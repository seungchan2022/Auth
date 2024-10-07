import Architecture
import Authentication
import Dashboard
import Domain
import Foundation
import LinkNavigator
import Platform

// MARK: - AppSideEffect

struct AppSideEffect: DependencyType, AuthenticationEnvironmentUsable, DashboardEnvironmentUsable {
  let toastViewModel: ToastViewActionType
  let authenticationUseCase: AuthenticationUseCase
  let chatUseCase: ChatUseCase

}

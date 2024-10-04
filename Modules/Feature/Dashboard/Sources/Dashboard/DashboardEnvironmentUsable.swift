import Architecture
import Domain

public protocol DashboardEnvironmentUsable {
  var toastViewModel: ToastViewActionType { get }
  var authenticationUseCase: AuthenticationUseCase { get }
}

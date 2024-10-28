import Architecture
import Domain

public protocol AuthenticationEnvironmentUsable {
  var toastViewModel: ToastViewActionType { get }
  var authenticationUseCase: AuthenticationUseCase { get }
  var chatUseCase: ChatUseCase { get }
}

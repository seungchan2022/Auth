import ComposableArchitecture
import DesignSystem
import SwiftUI

// MARK: - LandingPage

struct LandingPage {
  @Bindable var store: StoreOf<LandingReducer>
}

// MARK: View

extension LandingPage: View {
  var body: some View {
    ItemComponent(
      viewState: .init(),
      signInTapAction: { store.send(.routeToSignIn) },
      signUpTapAction: { store.send(.routeToSignUp) })
      .onDisappear {
        store.send(.teardown)
      }
  }
}

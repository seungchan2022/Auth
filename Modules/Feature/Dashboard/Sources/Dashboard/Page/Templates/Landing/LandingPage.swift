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
    VStack {
      Spacer()

      VStack(spacing: 12) {
        HStack {
          Image(systemName: "ellipsis.message.fill")
            .imageScale(.large)
            .foregroundStyle(.blue)

          Text("Messenger")
            .font(.title)
            .foregroundStyle(.blue)
        }

        Text("Your own conversation, the beginning of new communication")
          .font(.callout)
          .foregroundStyle(.gray)
          .multilineTextAlignment(.center)
      }
      .padding(.horizontal, 16)

      Spacer()

      VStack(spacing: 32) {
        Button(action: { store.send(.routeToSignIn) }) {
          Text("Sign In")
            .foregroundStyle(.white)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(.blue)
            .clipShape(.capsule)
        }

        Button(action: { store.send(.routeToSignUp) }) {
          Text("Sign Up")
            .foregroundStyle(.blue)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(
              Capsule()
                .stroke(.black, lineWidth: 1))
        }
      }
      .padding(.bottom, 64)
      .padding(.horizontal, 16)
    }
  }
}

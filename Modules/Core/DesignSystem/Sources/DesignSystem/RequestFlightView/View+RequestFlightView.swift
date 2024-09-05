import SwiftUI

extension View {

  @ViewBuilder
  public func setRequestFlightView(isLoading: Bool) -> some View {
    overlay(alignment: .center) {
      if isLoading {
        Rectangle()
          .fill(Color.black.opacity(0.13))
          .edgesIgnoringSafeArea(.all)
          .overlay(
            ProgressView("Loading")
              .progressViewStyle(.circular)
              .controlSize(.large))
      }
    }
  }
}

import ComposableArchitecture
import SwiftUI

// MARK: - HomePage

struct HomePage {
  @Bindable var store: StoreOf<HomeReducer>
}

extension HomePage { }

// MARK: View

extension HomePage: View {
  var body: some View {
    Text("Home Page")
  }
}

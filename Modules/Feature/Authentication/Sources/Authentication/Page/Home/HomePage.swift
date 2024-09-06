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
    VStack {
      Text("Home Page")

      Text("\(store.user.uid)")
      Text("\(store.user.email ?? "")")
      Text("\(store.user.userName ?? "")")
      Text("\(store.user.photoURL ?? "")")
    }
    .onAppear {
      store.send(.getUser)
    }
  }
}

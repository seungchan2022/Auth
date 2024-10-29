import ComposableArchitecture
import SwiftUI

// MARK: - MePage.SheetComponent

extension MePage {
  struct SheetComponent {
    let viewState: ViewState

    let deleteTapAction: () -> Void
    let takePhotoTapAction: () -> Void
    let selectTapAction: () -> Void

  }
}

extension MePage.SheetComponent { }

// MARK: - MePage.SheetComponent + View

extension MePage.SheetComponent: View {
  var body: some View {
    VStack(spacing: 24) {
      Button(action: { deleteTapAction() }) {
        HStack {
          Text("삭제")
            .font(.title3)
          Spacer()
        }
      }

      Divider()

      Button(action: { takePhotoTapAction() }) {
        HStack {
          Text("사진찍기")
            .font(.title3)
          Spacer()
        }
      }

      Divider()

      Button(action: { selectTapAction() }) {
        HStack {
          Text("앨범에서 선택")
            .font(.title3)
          Spacer()
        }
      }

      Divider()
    }
    .padding(.top, 24)
    .padding(.horizontal, 16)
    .presentationDetents([.fraction(0.3)])
  }
}

// MARK: - MePage.SheetComponent.ViewState

extension MePage.SheetComponent {
  struct ViewState: Equatable { }
}

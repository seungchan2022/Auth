import ComposableArchitecture
import SwiftUI

// MARK: - MePage.CarmeraComponent

extension MePage {
  struct CarmeraComponent: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss

    @Bindable var store: StoreOf<MeReducer>
  }
}

extension MePage.CarmeraComponent {
  class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: Lifecycle

    init(_ parent: MePage.CarmeraComponent) {
      self.parent = parent
    }

    // MARK: Internal

    let parent: MePage.CarmeraComponent

    func imagePickerController(
      _: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any])
    {
      // UIImage를 Data로 변환
      if
        let selectedImage = info[.originalImage] as? UIImage,
        let imageData = selectedImage.jpegData(compressionQuality: 0.8)
      { // JPEG로 압축
        parent.store.userCapturedImageData = imageData
        parent.store.send(.updateProfileImage(imageData))
      }
      parent.dismiss()
    }
  }

  func makeUIViewController(context: Context) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.delegate = context.coordinator
    picker.sourceType = .camera // 카메라 모드
    picker.allowsEditing = false // 사진 편집 비활성화
    return picker
  }

  func updateUIViewController(_: UIImagePickerController, context _: Context) { }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

}

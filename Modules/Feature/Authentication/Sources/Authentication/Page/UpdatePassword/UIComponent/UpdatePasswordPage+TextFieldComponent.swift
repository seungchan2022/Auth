import DesignSystem
import SwiftUI

// MARK: - UpdatePasswordPage.TextFieldComponent

extension UpdatePasswordPage {
  struct TextFieldComponent {
    let viewState: ViewState
    let title: String
    let placeholder: String
    let isSecure: Bool
    let errorMessage: String?
    let toggleAction: () -> Void
    var isFocused: FocusState<Focus?>.Binding
    let focusType: Focus

    @Binding var text: String
  }
}

extension UpdatePasswordPage.TextFieldComponent { }

// MARK: - UpdatePasswordPage.TextFieldComponent + View

extension UpdatePasswordPage.TextFieldComponent: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(title)

      Group {
        if isSecure {
          SecureField(placeholder, text: $text)
        } else {
          TextField(placeholder, text: $text)
        }
      }
      .textInputAutocapitalization(.never)
      .autocorrectionDisabled(true)

      Divider()
        .overlay(isFocused.wrappedValue == focusType ? .blue : .clear)

      if let errorMessage = errorMessage {
        Text(errorMessage)
          .font(.footnote)
          .foregroundColor(.red)
      }
    }
    .focused(isFocused, equals: focusType)
    .overlay(alignment: .trailing) {
      Button(action: { toggleAction() }) {
        Image(systemName: !isSecure ? "eye" : "eye.slash")
          .foregroundStyle(.black)
          .padding(.trailing, 12)
      }
    }
  }
}

// MARK: - UpdatePasswordPage.TextFieldComponent.ViewState

extension UpdatePasswordPage.TextFieldComponent {
  struct ViewState: Equatable { }
}

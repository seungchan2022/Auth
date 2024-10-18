import DesignSystem
import SwiftUI

// MARK: - SignUpPage.TextFieldComponent

extension SignUpPage {
  struct TextFieldComponent {
    let viewState: ViewState
    let title: String
    let placeholder: String
    let isSecure: Bool
    let errorMessage: String?
    let toggleAction: (() -> Void)?
    var isFocused: FocusState<SignUpFocus?>.Binding
    let focusType: SignUpFocus

    @Binding var text: String
  }
}

extension SignUpPage.TextFieldComponent { }

// MARK: - SignUpPage.TextFieldComponent + View

extension SignUpPage.TextFieldComponent: View {
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
      if let toggleAction = toggleAction {
        Button(action: { toggleAction() }) {
          Image(systemName: !isSecure ? "eye" : "eye.slash")
            .foregroundStyle(.black)
            .padding(.trailing, 12)
        }
      }
    }
  }
}

// MARK: - SignUpPage.TextFieldComponent.ViewState

extension SignUpPage.TextFieldComponent {
  struct ViewState: Equatable { }
}

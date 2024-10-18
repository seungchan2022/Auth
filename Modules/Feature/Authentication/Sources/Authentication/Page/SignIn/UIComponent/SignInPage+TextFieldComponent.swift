import DesignSystem
import SwiftUI

// MARK: - SignInPage.TextFieldComponent

extension SignInPage {
  struct TextFieldComponent {
    let viewState: ViewState
    let title: String
    let placeholder: String
    let isSecure: Bool
    let toggleAction: (() -> Void)?
    var isFocused: FocusState<SignInFocus?>.Binding
    let focusType: SignInFocus

    @Binding var text: String
  }
}

extension SignInPage.TextFieldComponent { }

// MARK: - SignInPage.TextFieldComponent + View

extension SignInPage.TextFieldComponent: View {
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

// MARK: - SignInPage.TextFieldComponent.ViewState

extension SignInPage.TextFieldComponent {
  struct ViewState: Equatable { }
}

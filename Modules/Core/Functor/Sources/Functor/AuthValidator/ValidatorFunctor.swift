import Foundation

public enum Validator {
  public static func validateEmail(email: String) -> Bool {
    let emailRegex = #"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}$"#

    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: email)
  }

  public static func validatePassword(password: String) -> Bool {
    let passwordRegex = "^(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,20}$"

    let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
    return passwordPredicate.evaluate(with: password)
  }
}

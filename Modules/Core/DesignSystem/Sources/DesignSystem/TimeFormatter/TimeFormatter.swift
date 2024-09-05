import Foundation

// MARK: - TimeFormatter

public enum TimeFormatter {
  /// `TimeInterval`을 "mm:ss" 형식의 문자열로 변환하는 함수
  public static func format(_ timeInterval: TimeInterval) -> String {
    timeInterval.formattedString
  }
}

// MARK: - TimeInterval Extension

extension TimeInterval {
  /// `TimeInterval`을 "mm:ss" 형식의 문자열로 변환
  public var formattedString: String {
    let minutes = Int(self) / 60
    let seconds = Int(self) % 60
    return String(format: "%d:%02d", minutes, seconds)
  }
}

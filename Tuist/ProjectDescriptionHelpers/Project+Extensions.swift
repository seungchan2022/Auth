import ProjectDescription

extension Settings {
  public static var defaultConfig: (Bool) -> Settings {
    { isDev in
      .settings(
        base: [
          "CODE_SIGN_IDENTITY": "iPhone Developer",
          "CODE_SIGN_STYLE": "Automatic",
          "Mode": isDev ? "Development" : "Production",
        ],
        configurations: [],
        defaultSettings: .recommended(excluding: .init()))
    }
  }
}

extension DeploymentTargets {
  public static var `default`: Self {
    .iOS("17.0")
  }
}

extension InfoPlist {
  public static var defaultInfoPlist: Self {
    extendingDefault(with: extraInfoPlist)
  }

  public static var extraInfoPlist: [String: Plist.Value] {
    [
      "UILaunchScreen": .dictionary([:]),
      "CFBundleURLTypes": .array([
        .dictionary([
          "CFBundleTypeRole": .string("Editor"),
          "CFBundleURLSchemes": .array([
            .string("com.googleusercontent.apps.299664057012-m93hc46hft1m50dir5168ospl50jvg30"),
          ]),
        ]),
      ]),
      "NSCameraUsageDescription": .string("프로필 이미지를 설정하기 위해 카메라 접근이 필요합니다."),
    ]
  }
}

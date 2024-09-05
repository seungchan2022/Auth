import ProjectDescription
import ProjectDescriptionHelpers

let targetList: [Target] = [
  .target(
    name: "Auth-Production",
    destinations: .iOS,
    product: .app,
    productName: "Auth",
    bundleId: "io.seungchan.auth",
    deploymentTargets: .default,
    infoPlist: .defaultInfoPlist,
    sources: ["Sources/**"],
    resources: ["Resources/**"],
    copyFiles: .none,
    headers: .none,
    entitlements: .none,
    scripts: [],
    dependencies: .default,
    settings: .defaultConfig(false),
    coreDataModels: [],
    environmentVariables: [:],
    launchArguments: [],
    additionalFiles: [],
    buildRules: [],
    mergedBinaryType: .disabled,
    mergeable: false),

  .target(
    name: "Auth-QA",
    destinations: .iOS,
    product: .app,
    productName: "Auth",
    bundleId: "io.seungchan.auth",
    deploymentTargets: .iOS("17.0"),
    infoPlist: .defaultInfoPlist,
    sources: ["Sources/**"],
    resources: ["Resources/**"],
    copyFiles: .none,
    headers: .none,
    entitlements: .none,
    scripts: [],
    dependencies: .default,
    settings: .defaultConfig(true),
    coreDataModels: [],
    environmentVariables: [:],
    launchArguments: [],
    additionalFiles: [],
    buildRules: [],
    mergedBinaryType: .disabled,
    mergeable: false),
]

let project: Project = .init(
  name: "AuthApplication",
  organizationName: "SeungChanMoon",
  options: .options(),
  packages: [],
  settings: .settings(),
  targets: targetList,
  schemes: [],
  fileHeaderTemplate: .none,
  additionalFiles: [],
  resourceSynthesizers: [])

extension [TargetDependency] {
  public static var `default`: [TargetDependency] {
    [
      //   .package(product: "Dashboard", type: .runtime),
    ]
  }
}

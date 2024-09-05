// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "Authentication",
  platforms: [.iOS(.v17)],
  products: [
    .library(
      name: "Authentication",
      targets: ["Authentication"]),
  ],
  dependencies: [
    .package(path: "../../../Core/Architecture"),
  ],
  targets: [
    .target(
      name: "Authentication",
      dependencies: [
        "Architecture",
      ]),
    .testTarget(
      name: "AuthenticationTests",
      dependencies: ["Authentication"]),
  ])

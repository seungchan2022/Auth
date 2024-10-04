// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "Dashboard",
  platforms: [.iOS(.v17)],
  products: [
    .library(
      name: "Dashboard",
      targets: ["Dashboard"]),
  ],
  dependencies: [
    .package(path: "../../../Core/Architecture"),
  ],
  targets: [
    .target(
      name: "Dashboard",
      dependencies: [
        "Architecture",
      ]),
    .testTarget(
      name: "DashboardTests",
      dependencies: ["Dashboard"]),
  ])

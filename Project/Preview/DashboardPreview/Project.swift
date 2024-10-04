import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .preview(
  projectName: "Dashboard",
  packages: [
    .local(path: .relativeToRoot("Modules/Feature/Dashboard")),
    .local(path: .relativeToRoot("Modules/Core/Domain")),
    .local(path: .relativeToRoot("Modules/Core/Platform")),
    .local(path: .relativeToRoot("Modules/Core/Functor")),
    .local(path: .relativeToRoot("Modules/Core/Architecture")),
    .local(path: .relativeToRoot("Modules/Core/DesignSystem")),
  ],
  dependencies: [
    .package(product: "Dashboard", type: .runtime),
  ])

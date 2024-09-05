import Foundation
import SwiftUI

// MARK: - DesignSystemColor

public enum DesignSystemColor: Equatable, CaseIterable {
  case background(BackgroundChip)
  case label(LabelChip)
  case palette(PaletteChip)
  case system(SystemChip)
  case tint(TintChip)
  case error(ErrorChip)
  case overlay(OverlayChip)

  // MARK: Public

  public static var allCases: [Self] {
    BackgroundChip.allCases.map(Self.background)
      + LabelChip.allCases.map(Self.label)
      + PaletteChip.allCases.map(Self.palette)
      + SystemChip.allCases.map(Self.system)
      + TintChip.allCases.map(Self.tint)
      + ErrorChip.allCases.map(Self.error)
      + OverlayChip.allCases.map(Self.overlay)
  }

  public var color: Color {
    switch self {
    case .background(let chip): chip.color
    case .label(let chip): chip.color
    case .palette(let chip): chip.color
    case .system(let chip): chip.color
    case .tint(let chip): chip.color
    case .error(let chip): chip.color
    case .overlay(let chip): chip.color
    }
  }
}

extension DesignSystemColor {

  public enum BackgroundChip: Equatable, CaseIterable {
    case green
    case blue

    var color: Color {
      switch self {
      case .green: Asset.ColorChip.Background.backgroundGreen.swiftUIColor
      case .blue: Asset.ColorChip.Background.backgroundBlue.swiftUIColor
      }
    }
  }

  public enum LabelChip: Equatable, CaseIterable {
    case `default`

    var color: Color {
      switch self {
      case .default: Asset.ColorChip.Label.labelDefault.swiftUIColor
      }
    }
  }

  public enum PaletteChip: Equatable, CaseIterable {

    case gray(GrayChip)

    // MARK: Public

    public enum GrayChip: Equatable, CaseIterable {
      case lv100
      case lv200
      case lv250
      case lv300
      case lv400

      var color: Color {
        switch self {
        case .lv100: Asset.ColorChip.Palette.Gray.paletteGray100.swiftUIColor
        case .lv200: Asset.ColorChip.Palette.Gray.paletteGray200.swiftUIColor
        case .lv250: Asset.ColorChip.Palette.Gray.paletteGray250.swiftUIColor
        case .lv300: Asset.ColorChip.Palette.Gray.paletteGray300.swiftUIColor
        case .lv400: Asset.ColorChip.Palette.Gray.paletteGray400.swiftUIColor
        }
      }
    }

    public static var allCases: [DesignSystemColor.PaletteChip] {
      PaletteChip.GrayChip.allCases.map(PaletteChip.gray)
    }

    // MARK: Internal

    var color: Color {
      switch self {
      case .gray(let chip): chip.color
      }
    }

  }

  public enum SystemChip: Equatable, CaseIterable {

    case black
    case white

    var color: Color {
      switch self {
      case .black: Asset.ColorChip.System.systemBlack.swiftUIColor
      case .white: Asset.ColorChip.System.systemWhite.swiftUIColor
      }
    }
  }

  public enum TintChip: Equatable, CaseIterable {

    case sand
    case purple
    case green
    case red

    var color: Color {
      switch self {
      case .sand: Asset.ColorChip.Tint.tintSand.swiftUIColor
      case .purple: Asset.ColorChip.Tint.tintPurple.swiftUIColor
      case .green: Asset.ColorChip.Tint.tintGreen.swiftUIColor
      case .red: Asset.ColorChip.Tint.tintRed.swiftUIColor
      }
    }
  }

  public enum ErrorChip: Equatable, CaseIterable {
    case `default`

    var color: Color {
      switch self {
      case .default: Asset.ColorChip.Error.errorDefault.swiftUIColor
      }
    }
  }

  public enum OverlayChip: Equatable, CaseIterable {
    case `default`

    var color: Color {
      switch self {
      case .default: Asset.ColorChip.Overlay.overlayDefault.swiftUIColor
      }
    }
  }
}

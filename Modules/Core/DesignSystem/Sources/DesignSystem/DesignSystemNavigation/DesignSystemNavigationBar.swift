import SwiftUI

// MARK: - DesignSystemNavigationBar

public struct DesignSystemNavigationBar {

  let backAction: BackAction?
  let title: String?
  let moreActionList: [MoreAction]

  public init(
    backAction: BackAction? = .none,
    title: String? = .none,
    moreActionList: [MoreAction] = [])
  {
    self.backAction = backAction
    self.moreActionList = moreActionList
    self.title = title
  }
}

extension DesignSystemNavigationBar {
  var tintColor: Color {
    DesignSystemColor.system(.black).color
  }

  var maxHeight: Double { 40 }
}

// MARK: View

extension DesignSystemNavigationBar: View {

  public var body: some View {
    Rectangle()
      .fill(.white)
      .overlay(alignment: .leading) {
        if let backAction = backAction {
          Button(action: backAction.action) {
            if let title = backAction.title {
              Text(title)
                .foregroundStyle(.black)
                .background {
                  Circle()
                    .fill(.clear)
                    .frame(width: 50, height: 50)
                }
                .padding(.horizontal, 16)
            }
            if let image = backAction.image {
              image
                .foregroundStyle(.black)
                .background {
                  Circle()
                    .fill(.clear)
                    .frame(width: 50, height: 50)
                }
                .padding(.horizontal, 16)
            }
          }
        } else {
          EmptyView()
        }
      }
      .overlay(alignment: .center) {
        if let title {
          Text(title)
            .foregroundStyle(.black)
        } else {
          EmptyView()
        }
      }
      .overlay(alignment: .trailing) {
        HStack(spacing: 8) {
          ForEach(moreActionList, id: \.id) { item in
            Button(action: item.action) {
              if let title = item.title {
                Text(title)
                  .font(.system(size: 16, weight: .regular, design: .default))
                  .multilineTextAlignment(.trailing)
                  .foregroundStyle(tintColor)
                  .fixedSize(horizontal: false, vertical: true)
                  .frame(minWidth: 40)
              }
              if let image = item.image {
                image
                  .foregroundStyle(tintColor)
                  .frame(minWidth: 40)
              }
            }
          }
        }
        .padding(.horizontal, 16)
      }

      .frame(maxWidth: .infinity)
      .frame(height: maxHeight)
  }
}

// MARK: DesignSystemNavigationBar.BackAction

extension DesignSystemNavigationBar {
  public struct BackAction {
    let title: String?
    let image: Image?
    let action: () -> Void

    public init(
      title: String? = .none,
      image: Image? = .none,
      action: @escaping () -> Void)
    {
      self.title = title
      self.image = image
      self.action = action
    }
  }
}

// MARK: DesignSystemNavigationBar.MoreAction

extension DesignSystemNavigationBar {

  public struct MoreAction: Equatable, Identifiable {

    // MARK: Lifecycle

    public init(
      title: String? = .none,
      image: Image? = .none,
      action: @escaping () -> Void)
    {
      self.title = title
      self.image = image
      self.action = action
    }

    // MARK: Public

    public var id: String {
      if let title = title {
        return title
      }

      return UUID().uuidString
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.id == rhs.id
    }

    // MARK: Internal

    let title: String?
    let image: Image?
    let action: () -> Void
  }
}

#Preview("Case1") {
  VStack {
    DesignSystemNavigationBar(
      backAction: DesignSystemNavigationBar.BackAction(
        image: Image(systemName: "chevron.left"),
        action: { }),
      moreActionList: [
        .init(title: "Create", action: { }),
        .init(title: "Done", action: { }),
      ])
    Spacer()
  }
}

#Preview("Case2") {
  VStack {
    DesignSystemNavigationBar(
      backAction: DesignSystemNavigationBar.BackAction(
        image: Image(systemName: "chevron.left"),
        action: { }),
      title: "로그인/보안",
      moreActionList: [
        .init(image: Image(systemName: "plus"), action: { }),
      ])
    Spacer()
  }
}

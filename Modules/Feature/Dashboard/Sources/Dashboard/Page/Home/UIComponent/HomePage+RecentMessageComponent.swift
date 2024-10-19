import ComposableArchitecture
import DesignSystem
import Domain
import FirebaseAuth
import Foundation
import SwiftUI

// MARK: - HomePage.RecentMessageComponent

extension HomePage {
  struct RecentMessageComponent {
    let viewState: ViewState
    let tapAction: () -> Void
  }
}

extension HomePage.RecentMessageComponent {
  private var isImage: Bool {
    // 이미지 확장자 목록 정의
    let imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "webp"]
    // url이면서 이미지 확장자에 부합하는지 확인
    guard
      let url = URL(string: viewState.item.messageText),
      imageExtensions.contains(url.pathExtension.lowercased())
    else {
      return false
    }
    return true
  }
}

// MARK: - HomePage.RecentMessageComponent + View

extension HomePage.RecentMessageComponent: View {
  var body: some View {
    Button(action: { tapAction() }) {
      VStack {
        HStack {
          if let user = viewState.userList.first(where: { $0.uid == viewState.item.fromId || $0.uid == viewState.item.toId }) {
            RemoteImage(url: user.photoURL ?? "") {
              Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 64, height: 64)
                .clipShape(Circle())
            }
            .scaledToFill()
            .frame(width: 64, height: 64)
            .clipShape(Circle())
          }

          VStack(alignment: .leading) {
            if let user = viewState.userList.first(where: { $0.uid == viewState.item.fromId || $0.uid == viewState.item.toId }) {
              Text(user.userName ?? "")
                .font(.callout)
                .fontWeight(.bold)
            }

            if isImage {
              Text("사진")
                .font(.footnote)
                .lineLimit(.zero)
            } else {
              Text(viewState.item.messageText)
                .font(.footnote)
                .lineLimit(.zero)
            }
          }

          Spacer()

          HStack {
            Text(viewState.item.date.timestampString())

            Image(systemName: "chevron.right")
              .imageScale(.small)
          }
        }
        .padding(.horizontal, 12)

        Divider()
          .padding(.leading, 80)
      }
      .frame(maxWidth: .infinity)
    }
  }
}

// MARK: - HomePage.RecentMessageComponent.ViewState

extension HomePage.RecentMessageComponent {
  struct ViewState: Equatable {
    let item: Chat.Message.Item
    let userList: [Authentication.Me.Response]
  }
}

extension Date {

  // MARK: Fileprivate

  fileprivate func timestampString() -> String {
    if Calendar.current.isDateInToday(self) {
      return timeFormatter.string(from: self)
    } else if Calendar.current.isDateInYesterday(self) {
      return "Yesterday"
    } else {
      return dayFormatter.string(from: self)
    }
  }

  // MARK: Private

  private var timeFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.dateFormat = "HH:mm"
    return formatter
  }

  private var dayFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.timeStyle = .medium
    formatter.dateFormat = "MM/dd/yy"
    return formatter
  }
}

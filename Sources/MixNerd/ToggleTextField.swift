import AppKit
import SwiftUI
import WebKit

struct ToggleTextField: View {
  let label: String
  @Binding var oldValue: String
  @Binding var newValue: String

  var body: some View {
    HStack {
      TextField(
        label,
        text: $newValue
      )
      .background(Color.yellow.opacity(newValue != oldValue ? 0.2 : 0.0))

      Button {
        newValue = oldValue
      } label: {
        Image(systemName: "arrow.uturn.backward")
      }
      .buttonStyle(.borderless)
      .disabled(newValue == oldValue)
      .help("Reset to: \(oldValue)")
      .onHover { inside in
        if inside {
          NSCursor.pointingHand.push()
        } else {
          NSCursor.pop()
        }
      }
    }
  }
}

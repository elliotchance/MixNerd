import AppKit
import SwiftUI

@main
@MainActor
struct MixNerdApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    WindowGroup {
      TracklistEditorWebView()
    }
    .defaultSize(width: 1200, height: 800)
    .commands {
      CommandGroup(replacing: .newItem) {}
    }
  }
}

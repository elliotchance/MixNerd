import SwiftUI
import WebKit

struct CustomWebView: NSViewRepresentable { // macOS, not iOS
    let url: URL

    func makeNSView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.load(URLRequest(url: url))
    }
}

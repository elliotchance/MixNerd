import SwiftUI
import WebKit

struct CustomWebView: NSViewRepresentable { // macOS, not iOS
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.load(URLRequest(url: url))
    }

    class Coordinator: NSObject, WKNavigationDelegate {

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let currentTitle = webView.title ?? ""
            DispatchQueue.main.async {
                UserDefaults.standard.set(currentTitle, forKey: "pageTitle")
                if let currentURL = webView.url?.absoluteString {
                    UserDefaults.standard.set(currentURL, forKey: "currentURLString")
                }
            }
        }
    }
}

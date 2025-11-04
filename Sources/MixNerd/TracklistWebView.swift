import SwiftUI
import WebKit

struct TracklistWebView: NSViewRepresentable { // macOS, not iOS
    let url: URL
    let setMetadata: @Sendable (TracklistMetadata) -> Void
    func makeCoordinator() -> Coordinator {
        Coordinator(setMetadata: setMetadata)
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
        let setMetadata: @Sendable (TracklistMetadata) -> Void
        init(setMetadata: @escaping @Sendable (TracklistMetadata) -> Void) {
            self.setMetadata = setMetadata
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async(execute: { [setMetadata = self.setMetadata] in
                let currentTitle = webView.title ?? ""
                UserDefaults.standard.set(currentTitle, forKey: "pageTitle")
                if let currentURL = webView.url?.absoluteString {
                    UserDefaults.standard.set(currentURL, forKey: "currentURLString")
                }

                // Extract background image URL from div#bgArt
                let js = """
                (function() {
                  var el = document.getElementById('artworkLeft');
                  if (!el) { return ''; }
                  var bg = window.getComputedStyle(el).backgroundImage || el.style.backgroundImage || '';
                  return bg.substr(5, bg.length-7);
                })();
                """
                var artworkURL = ""
                webView.evaluateJavaScript(js) { result, _ in
                    if let urlString = result as? String, !urlString.isEmpty {
                        UserDefaults.standard.set(urlString, forKey: "bgArtURLString")
                        artworkURL = urlString
                    }
                }

                setMetadata(TracklistMetadata(artworkURL: artworkURL, date: "2000-01-01", artist: "", title: currentTitle, source: ""))
            })
        }
    }
}

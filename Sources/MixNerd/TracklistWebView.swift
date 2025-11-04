import SwiftUI
import WebKit

struct TracklistWebView: NSViewRepresentable { // macOS, not iOS
    let url: URL
    let setTracklist: @Sendable (Tracklist?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(setTracklist: setTracklist)
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
        let setTracklist: @Sendable (Tracklist?) -> Void

        init(setTracklist: @escaping @Sendable (Tracklist?) -> Void) {
            self.setTracklist = setTracklist
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async(execute: { [setTracklist = self.setTracklist] in
                let currentURL = webView.url?.absoluteString ?? ""
                if !currentURL.hasPrefix("https://www.1001tracklists.com/tracklist/") {
                    setTracklist(nil)
                    return
                }

                let currentTitle = webView.title ?? ""

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

                setTracklist(Tracklist(
                    artworkURL: artworkURL,
                    date: TitleParser().parseDate(currentTitle),
                    artist: TitleParser().parseArtist(currentTitle),
                    title: TitleParser().parseTitle(currentTitle),
                    source: "",
                ))
            })
        }
    }
}

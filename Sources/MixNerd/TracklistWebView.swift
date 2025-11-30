import SwiftUI
import WebKit

struct TracklistWebView: NSViewRepresentable {  // macOS, not iOS
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

  func searchForTracklist(name: String) {
    // TODO: We might need to redirect to a search page first.
    // let url = URL(string: "https://www.1001tracklists.com/")!

    let js = """
        function () { $('#sBoxInput').val('\(name)'); $('#sBoxBtn').click(); }();
      """
    nsView.evaluateJavaScript(js) { result, _ in
      print("result: \(result)")
    }
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
        var tracklist = Tracklist(
          date: TitleParser().parseDate(currentTitle),
          artist: TitleParser().parseArtist(currentTitle),
          title: TitleParser().parseTitle(currentTitle),
          source: "",
        )

        // Extract artwork
        let js = """
          (function() {
            var el = document.getElementById('artworkLeft');
            if (!el) { return ''; }
            var bg = window.getComputedStyle(el).backgroundImage || el.style.backgroundImage || '';
            return bg.substr(5, bg.length-7);
          })();
          """
        webView.evaluateJavaScript(js) { result, _ in
          if let urlString = result as? String, !urlString.isEmpty {
            tracklist.artwork = NSImage(contentsOf: URL(string: urlString)!)
          }

          setTracklist(tracklist)
        }

        // Extract the short link
        let jsShortLink = """
          (function() {
              return $("div").filter(function() {
                  return $(this).text().trim() === "Short link";
              }).next("div").text().trim();
          })();
          """
        webView.evaluateJavaScript(jsShortLink) { result, _ in
          if let shortLink = result as? String {
            tracklist.shortLink = shortLink
          }
          setTracklist(tracklist)
        }

        // Extract the genre
        let jsGenre = """
          (function() {
              return $("#tl_music_styles").text().trim();
          })();
          """
        webView.evaluateJavaScript(jsGenre) { result, _ in
          if let genre = result as? String {
            tracklist.genre = genre
          }
          setTracklist(tracklist)
        }

        // Extract the source
        let jsSource = """
          (function() {
              return $('h1 a[href^="/source/"]').text();
          })();
          """
        webView.evaluateJavaScript(jsSource) { result, _ in
          if let source = result as? String {
            tracklist.source = source
          }
          setTracklist(tracklist)
        }

        // Extract the tracks
        let jsTracks = """
          (function() {
              const trackStarts = [];
              $("div.bItm").each((i, t) => {
                  const text = $(t).text();
                  if (text.includes('correct cue time is')) {
                      const startTime = $(t).find('.italic').text().trim();
                      trackStarts[trackStarts.length-1] = startTime;
                  } else if (!text.match(/^\\s*\\d+\\s+/)) {
                      // Avoid (trimmed) - these are not tracks:
                      //  1:16:31Estiva - Peppa[25-10-22 19:04:00]akselek
                      //  w/   1:50:38      Estiva - Via Infinita  COLORIZE (ENHANCED)
                      //  track wasn't played[25-10-20 23:34:30]biscram[poll:0/1/0]
                      return
                  } else {
                      const startTime = $(t).find(".cue:last-of-type").text();
                      trackStarts.push(startTime);
                  }
              });

              let trackNumber = 1;
              const data = [];
              $("div.bItm.tlpItem").each((_, t) => {
                  if (!$(t).text().match(/^\\s*\\d+\\s+/)) {
                      return
                  }
                  const parts = (
                      $(t).find("meta[itemprop=name]").attr("content") || $(t).find('span.trackValue').text()
                  ).split(" - ", 2);
                  data.push({
                    artist: parts[0].trim(),
                    title: parts[1].trim(),
                    time: trackStarts[trackNumber-1],
                    label: $(t).find("span[title=label]").text().trim(),
                  });
                  ++trackNumber;
              });

              return data;
          })();
          """
        webView.evaluateJavaScript(jsTracks) { result, _ in
          if let tracks = result as? [Any] {
            for track in tracks {
              if let track = track as? [String: Any] {
                tracklist.tracks.append(
                  Track(
                    time: String(describing: track["time"] ?? ""),
                    artist: String(describing: track["artist"] ?? ""),
                    title: String(describing: track["title"] ?? ""),
                    label: String(describing: track["label"] ?? ""),
                  ))
              }
            }
          }

          setTracklist(tracklist)
        }
      })
    }
  }
}

import SwiftUI
import WebKit

class NavigationState: ObservableObject {
  @Published var canGoBack: Bool = false
  @Published var canGoForward: Bool = false
  @Published var currentURL: URL?
}

struct TracklistWebView: NSViewRepresentable {
  let url: URL
  let setTracklist: @Sendable (Tracklist?) -> Void
  let navigationState: NavigationState

  // Store coordinator reference to access from instance methods
  private class CoordinatorReference {
    weak var coordinator: Coordinator?
  }
  private let coordinatorRef = CoordinatorReference()

  func makeCoordinator() -> Coordinator {
    let coordinator = Coordinator(setTracklist: setTracklist, navigationState: navigationState)
    coordinatorRef.coordinator = coordinator
    return coordinator
  }

  func makeNSView(context: Context) -> WKWebView {
    let webView = WKWebView()

    // This is importsnt to make sure challange requests do not happen on every page load.
    webView.configuration.websiteDataStore = .default()  // ensure persistent cookies

    webView.navigationDelegate = context.coordinator
    context.coordinator.webView = webView
    coordinatorRef.coordinator = context.coordinator

    // Observe navigation state changes
    webView.addObserver(context.coordinator, forKeyPath: "canGoBack", options: [.new], context: nil)
    webView.addObserver(
      context.coordinator, forKeyPath: "canGoForward", options: [.new], context: nil)
    context.coordinator.hasObservers = true

    // Initialize navigation state
    Task { @MainActor in
      navigationState.canGoBack = webView.canGoBack
      navigationState.canGoForward = webView.canGoForward
      navigationState.currentURL = webView.url ?? url
    }

    return webView
  }

  func updateNSView(_ nsView: WKWebView, context: Context) {
    context.coordinator.webView = nsView
    coordinatorRef.coordinator = context.coordinator

    // Ensure observers are set up if not already
    if !context.coordinator.hasObservers {
      nsView.addObserver(
        context.coordinator, forKeyPath: "canGoBack", options: [.new], context: nil)
      nsView.addObserver(
        context.coordinator, forKeyPath: "canGoForward", options: [.new], context: nil)
      context.coordinator.hasObservers = true
    }

    // Only load if URL has changed
    if context.coordinator.currentURL != url {
      context.coordinator.currentURL = url
      nsView.load(URLRequest(url: url))
    }
  }

  @MainActor
  func searchForTracklist(name: String) {
    coordinatorRef.coordinator?.searchForTracklist(name: name)
  }

  @MainActor
  func navigateToURL(_ url: URL) {
    coordinatorRef.coordinator?.navigateToURL(url)
  }

  @MainActor
  func goBack() {
    coordinatorRef.coordinator?.goBack()
  }

  @MainActor
  func goForward() {
    coordinatorRef.coordinator?.goForward()
  }

  @MainActor
  func reload() {
    coordinatorRef.coordinator?.reload()
  }

  class Coordinator: NSObject, WKNavigationDelegate {
    let setTracklist: @Sendable (Tracklist?) -> Void
    nonisolated(unsafe) let navigationState: NavigationState
    weak var webView: WKWebView?
    var hasObservers: Bool = false
    var currentURL: URL?

    init(setTracklist: @escaping @Sendable (Tracklist?) -> Void, navigationState: NavigationState) {
      self.setTracklist = setTracklist
      self.navigationState = navigationState
    }

    deinit {
      if hasObservers {
        webView?.removeObserver(self, forKeyPath: "canGoBack")
        webView?.removeObserver(self, forKeyPath: "canGoForward")
      }
    }

    override func observeValue(
      forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?,
      context: UnsafeMutableRawPointer?
    ) {
      guard let webView = webView else { return }
      nonisolated(unsafe) let navState = navigationState

      DispatchQueue.main.async {
        if keyPath == "canGoBack" {
          navState.canGoBack = webView.canGoBack
        } else if keyPath == "canGoForward" {
          navState.canGoForward = webView.canGoForward
        }
      }
    }

    @MainActor
    func goBack() {
      webView?.goBack()
    }

    @MainActor
    func goForward() {
      webView?.goForward()
    }

    @MainActor
    func reload() {
      webView?.reload()
    }

    @MainActor
    func searchForTracklist(name: String) {
      nonisolated(unsafe) let navState = navigationState
      if !(navState.currentURL?.host?.contains("1001tracklists.com") ?? false) {
        navigateToURL(URL(string: "https://www.1001tracklists.com/")!)
        return
      }

      guard let webView = webView else { return }
      let js = """
          $('#sBoxInput').val('\(name)');
          $('#sBoxBtn').click();
        """
      webView.evaluateJavaScript(js)
    }

    @MainActor
    func navigateToURL(_ url: URL) {
      guard let webView = webView else { return }
      webView.load(URLRequest(url: url))
      // Update URL immediately for better UX
      nonisolated(unsafe) let navState = navigationState
      DispatchQueue.main.async {
        navState.currentURL = url
      }
    }

    func attemptToExtractTracklist(webView: WKWebView) {
      DispatchQueue.main.async(execute: { [setTracklist = self.setTracklist] in
        let currentURL = webView.url?.absoluteString ?? ""
        if !currentURL.hasPrefix("https://www.1001tracklists.com/tracklist/") {
          setTracklist(nil)
          return
        }

        // Extract all tracklist data in a single JavaScript execution
        let jsExtractAll = """
          (function() {
              const result = {
                  duration: null,
                  artwork: null,
                  shortLink: null,
                  genre: null,
                  source: null,
                  tracks: []
              };

              // Extract duration
              const durationMatch = $('li.tBtn').text().match(/\\[((\\d+:)?(\\d+):(\\d+))\\]/);
              if (durationMatch) {
                  result.duration = durationMatch[1];
              }

              // Extract artwork
              const el = document.getElementById('artworkLeft');
              if (el) {
                  const bg = window.getComputedStyle(el).backgroundImage || el.style.backgroundImage || '';
                  if (bg) {
                      result.artwork = bg.substr(5, bg.length-7);
                  }
              }

              // Extract short link
              const shortLinkDiv = $("div").filter(function() {
                  return $(this).text().trim() === "Short link";
              }).next("div").text().trim();
              if (shortLinkDiv) {
                  result.shortLink = shortLinkDiv;
              }

              // Extract genre
              const genre = $("#tl_music_styles").text().trim();
              if (genre) {
                  result.genre = genre;
              }

              // Extract source
              const source = $('h1 a[href^="/source/"]').text();
              if (source) {
                  result.source = source;
              }

              // Extract tracks
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
                      return;
                  } else {
                      const startTime = $(t).find(".cue:last-of-type").text();
                      trackStarts.push(startTime);
                  }
              });

              let trackNumber = 1;
              $("div.bItm.tlpItem").each((_, t) => {
                  if (!$(t).text().match(/^\\s*\\d+\\s+/)) {
                      return;
                  }
                  const parts = (
                      $(t).find("meta[itemprop=name]").attr("content") || $(t).find('span.trackValue').text()
                  ).split(" - ", 2);
                  result.tracks.push({
                      artist: parts[0].trim(),
                      title: parts[1].trim(),
                      time: trackStarts[trackNumber-1],
                      label: $(t).find("span[title=label]").text().trim(),
                  });
                  ++trackNumber;
              });

              return result;
          })();
          """
        webView.evaluateJavaScript(jsExtractAll) { result, _ in
          guard let data = result as? [String: Any] else {
            setTracklist(nil)
            return
          }

          let currentTitle = webView.title ?? ""
          var tracklist = Tracklist(
            artwork: Artwork(),
            date: TitleParser().parseDate(currentTitle),
            artist: TitleParser().parseArtist(currentTitle),
            title: TitleParser().parseTitle(currentTitle),
            source: "",
            genre: "",
            comment: "",
            tracks: [],
            grouping: "",
            shortLink: nil,
            duration: Time(),
            audioFilePath: nil,
            artistComponent: TitleParser().parseArtist(currentTitle),
            titleComponent: TitleParser().parseTitle(currentTitle),
            genreComponent: "",
          )

          // Extract duration
          if let duration = data["duration"] as? String {
            tracklist.duration = Time(string: duration)
          }

          // Extract artwork
          if let artworkURL = data["artwork"] as? String, !artworkURL.isEmpty,
            let url = URL(string: artworkURL)
          {
            tracklist.artwork = Artwork(fromURL: url)
          }

          // Extract short link
          if let shortLink = data["shortLink"] as? String {
            tracklist.shortLink = URL(string: "https://\(shortLink)")
          }

          // Extract genre
          if let genre = data["genre"] as? String {
            tracklist.genre = genre
            tracklist.genreComponent = genre
          }

          // Extract source
          if let source = data["source"] as? String {
            tracklist.source = source
          }

          // Extract tracks
          if let tracks = data["tracks"] as? [Any] {
            for track in tracks {
              if let track = track as? [String: Any] {
                tracklist.tracks.append(
                  Track(
                    time: Time(string: String(describing: track["time"] ?? "")),
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

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      self.attemptToExtractTracklist(webView: webView)

      // Update navigation state after page loads
      nonisolated(unsafe) let navState = navigationState
      DispatchQueue.main.async {
        navState.canGoBack = webView.canGoBack
        navState.canGoForward = webView.canGoForward
        navState.currentURL = webView.url
      }
    }
  }
}

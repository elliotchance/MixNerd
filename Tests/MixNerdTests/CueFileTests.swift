import Testing

@testable import MixNerd

struct CueFileTests {

  // @Test("Parse basic CUE file")
  // func testParseBasicCueFile() {
  //   let cueContent = """
  //     PERFORMER "Armin van Buuren"
  //     TITLE "A State of Trance 1248"
  //     FILE "asot1248.mp3" WAVE
  //       TRACK 01 AUDIO
  //         TITLE "Love In Traffic"
  //         PERFORMER "Satoshi Tomiie"
  //         INDEX 01 00:00:00
  //       TRACK 02 AUDIO
  //         TITLE "Lost Vagueness"
  //         PERFORMER "Utah Saints"
  //         INDEX 01 06:18:00
  //       TRACK 03 AUDIO
  //         TITLE "Adagio For Strings"
  //         PERFORMER "Tiesto"
  //         INDEX 01 12:36:00
  //     """

  //   let tracklist = CueFile.parse(cueContent)

  //   #expect(tracklist != nil)
  //   #expect(tracklist?.artist == "Armin van Buuren")
  //   #expect(tracklist?.title == "A State of Trance 1248")
  //   #expect(tracklist?.source == "asot1248.mp3")
  //   #expect(tracklist?.tracks.count == 3)

  //   #expect(tracklist?.tracks[0].time == "00:00")
  //   #expect(tracklist?.tracks[0].artist == "Satoshi Tomiie")
  //   #expect(tracklist?.tracks[0].title == "Love In Traffic")

  //   #expect(tracklist?.tracks[1].time == "06:18")
  //   #expect(tracklist?.tracks[1].artist == "Utah Saints")
  //   #expect(tracklist?.tracks[1].title == "Lost Vagueness")

  //   #expect(tracklist?.tracks[2].time == "12:36")
  //   #expect(tracklist?.tracks[2].artist == "Tiesto")
  //   #expect(tracklist?.tracks[2].title == "Adagio For Strings")
  // }

  // @Test("Parse CUE file with track using album artist")
  // func testParseCueFileWithAlbumArtist() {
  //   let cueContent = """
  //     PERFORMER "Armin van Buuren"
  //     TITLE "A State of Trance 1248"
  //     FILE "asot1248.mp3" WAVE
  //       TRACK 01 AUDIO
  //         TITLE "Love In Traffic"
  //         INDEX 01 00:00:00
  //       TRACK 02 AUDIO
  //         TITLE "Lost Vagueness"
  //         PERFORMER "Utah Saints"
  //         INDEX 01 06:18:00
  //     """

  //   let tracklist = CueFile.parse(cueContent)

  //   #expect(tracklist != nil)
  //   #expect(tracklist?.tracks.count == 2)

  //   // First track should use album artist
  //   #expect(tracklist?.tracks[0].artist == "Armin van Buuren")
  //   #expect(tracklist?.tracks[0].title == "Love In Traffic")

  //   // Second track has its own artist
  //   #expect(tracklist?.tracks[1].artist == "Utah Saints")
  //   #expect(tracklist?.tracks[1].title == "Lost Vagueness")
  // }

  // @Test("Parse CUE file with comments and empty lines")
  // func testParseCueFileWithComments() {
  //   let cueContent = """
  //     REM COMMENT "This is a comment"
  //     PERFORMER "Armin van Buuren"
  //     REM Another comment
  //     TITLE "A State of Trance 1248"

  //     FILE "asot1248.mp3" WAVE
  //       TRACK 01 AUDIO
  //         TITLE "Love In Traffic"
  //         INDEX 01 00:00:00
  //     """

  //   let tracklist = CueFile.parse(cueContent)

  //   #expect(tracklist != nil)
  //   #expect(tracklist?.artist == "Armin van Buuren")
  //   #expect(tracklist?.title == "A State of Trance 1248")
  //   #expect(tracklist?.tracks.count == 1)
  // }

  // @Test("Parse CUE file with missing fields")
  // func testParseCueFileWithMissingFields() {
  //   let cueContent = """
  //     FILE "audio.mp3" WAVE
  //       TRACK 01 AUDIO
  //         TITLE "Track 1"
  //         INDEX 01 00:00:00
  //       TRACK 02 AUDIO
  //         INDEX 01 05:30:00
  //     """

  //   let tracklist = CueFile.parse(cueContent)

  //   #expect(tracklist != nil)
  //   #expect(tracklist?.artist == "")
  //   #expect(tracklist?.title == "")
  //   #expect(tracklist?.source == "audio.mp3")
  //   #expect(tracklist?.tracks.count == 2)
  //   #expect(tracklist?.tracks[0].title == "Track 1")
  //   #expect(tracklist?.tracks[1].title == "")
  // }

  // @Test("Parse empty CUE file returns nil")
  // func testParseEmptyCueFile() {
  //   let tracklist = CueFile.parse("")
  //   #expect(tracklist == nil)
  // }

  // @Test("Write basic tracklist to CUE format")
  // func testWriteBasicTracklist() {
  //   var tracklist = Tracklist()
  //   tracklist.artist = "Armin van Buuren"
  //   tracklist.title = "A State of Trance 1248"
  //   tracklist.source = "asot1248.mp3"
  //   tracklist.tracks = [
  //     Track(time: "00:00", artist: "Satoshi Tomiie", title: "Love In Traffic"),
  //     Track(time: "06:18", artist: "Utah Saints", title: "Lost Vagueness"),
  //     Track(time: "12:36", artist: "Tiesto", title: "Adagio For Strings"),
  //   ]

  //   let cueContent = CueFile.write(tracklist)

  //   #expect(cueContent.contains("PERFORMER \"Armin van Buuren\""))
  //   #expect(cueContent.contains("TITLE \"A State of Trance 1248\""))
  //   #expect(cueContent.contains("FILE \"asot1248.mp3\" WAVE"))
  //   #expect(cueContent.contains("TRACK 01 AUDIO"))
  //   #expect(cueContent.contains("TRACK 02 AUDIO"))
  //   #expect(cueContent.contains("TRACK 03 AUDIO"))
  //   #expect(cueContent.contains("TITLE \"Love In Traffic\""))
  //   #expect(cueContent.contains("PERFORMER \"Satoshi Tomiie\""))
  //   #expect(cueContent.contains("INDEX 01 00:00:00"))
  //   #expect(cueContent.contains("INDEX 01 06:18:00"))
  //   #expect(cueContent.contains("INDEX 01 12:36:00"))
  // }

  // @Test("Write tracklist with custom audio filename")
  // func testWriteTracklistWithCustomFilename() {
  //   var tracklist = Tracklist()
  //   tracklist.artist = "Test Artist"
  //   tracklist.title = "Test Album"
  //   tracklist.tracks = [
  //     Track(time: "00:00", artist: "Artist 1", title: "Track 1")
  //   ]

  //   let cueContent = CueFile.write(tracklist, audioFileName: "custom.mp3")

  //   #expect(cueContent.contains("FILE \"custom.mp3\" WAVE"))
  // }

  // @Test("Write tracklist omits track performer when same as album artist")
  // func testWriteTracklistOmitsDuplicatePerformer() {
  //   var tracklist = Tracklist()
  //   tracklist.artist = "Armin van Buuren"
  //   tracklist.title = "Album"
  //   tracklist.tracks = [
  //     Track(time: "00:00", artist: "Armin van Buuren", title: "Track 1"),
  //     Track(time: "05:00", artist: "Different Artist", title: "Track 2"),
  //   ]

  //   let cueContent = CueFile.write(tracklist)

  //   // First track should not have PERFORMER (same as album)
  //   let lines = cueContent.components(separatedBy: .newlines)
  //   var track1Lines: [String] = []
  //   var track2Lines: [String] = []
  //   var inTrack1 = false
  //   var inTrack2 = false

  //   for line in lines {
  //     if line.contains("TRACK 01") {
  //       inTrack1 = true
  //       inTrack2 = false
  //     } else if line.contains("TRACK 02") {
  //       inTrack1 = false
  //       inTrack2 = true
  //     }

  //     if inTrack1 && !line.contains("TRACK 01") {
  //       track1Lines.append(line)
  //     } else if inTrack2 {
  //       track2Lines.append(line)
  //     }
  //   }

  //   // Track 1 should not have PERFORMER line
  //   let track1HasPerformer = track1Lines.contains { $0.contains("PERFORMER") }
  //   #expect(track1HasPerformer == false)

  //   // Track 2 should have PERFORMER line
  //   let track2HasPerformer = track2Lines.contains { $0.contains("PERFORMER") }
  //   #expect(track2HasPerformer == true)
  // }

  // @Test("Write tracklist with empty fields")
  // func testWriteTracklistWithEmptyFields() {
  //   var tracklist = Tracklist()
  //   tracklist.tracks = [
  //     Track(time: "00:00", artist: "", title: "Track 1")
  //   ]

  //   let cueContent = CueFile.write(tracklist)

  //   // Should not contain PERFORMER or TITLE headers if empty
  //   #expect(!cueContent.contains("PERFORMER \"\""))
  //   #expect(!cueContent.contains("TITLE \"\""))
  //   // But should still have FILE and TRACK
  //   #expect(cueContent.contains("FILE"))
  //   #expect(cueContent.contains("TRACK 01"))
  // }

  // @Test("Write tracklist escapes quotes in strings")
  // func testWriteTracklistEscapesQuotes() {
  //   var tracklist = Tracklist()
  //   tracklist.artist = "Artist with \"quotes\""
  //   tracklist.title = "Title with \"quotes\""
  //   tracklist.tracks = [
  //     Track(time: "00:00", artist: "Track \"Artist\"", title: "Track \"Title\"")
  //   ]

  //   let cueContent = CueFile.write(tracklist)

  //   // Should escape quotes
  //   #expect(cueContent.contains("PERFORMER \"Artist with \\\"quotes\\\"\""))
  //   #expect(cueContent.contains("TITLE \"Title with \\\"quotes\\\"\""))
  //   #expect(cueContent.contains("PERFORMER \"Track \\\"Artist\\\"\""))
  //   #expect(cueContent.contains("TITLE \"Track \\\"Title\\\"\""))
  // }

  // @Test("Round-trip: parse then write")
  // func testRoundTrip() {
  //   let originalCue = """
  //     PERFORMER "Armin van Buuren"
  //     TITLE "A State of Trance 1248"
  //     FILE "asot1248.mp3" WAVE
  //       TRACK 01 AUDIO
  //         TITLE "Love In Traffic"
  //         PERFORMER "Satoshi Tomiie"
  //         INDEX 01 00:00:00
  //       TRACK 02 AUDIO
  //         TITLE "Lost Vagueness"
  //         PERFORMER "Utah Saints"
  //         INDEX 01 06:18:00
  //     """

  //   guard let tracklist = CueFile.parse(originalCue) else {
  //     Issue.record("Failed to parse CUE file")
  //     return
  //   }

  //   let writtenCue = CueFile.write(tracklist, audioFileName: "asot1248.mp3")

  //   // Parse the written CUE file
  //   guard let parsedAgain = CueFile.parse(writtenCue) else {
  //     Issue.record("Failed to parse written CUE file")
  //     return
  //   }

  //   // Verify data integrity
  //   #expect(parsedAgain.artist == tracklist.artist)
  //   #expect(parsedAgain.title == tracklist.title)
  //   #expect(parsedAgain.source == tracklist.source)
  //   #expect(parsedAgain.tracks.count == tracklist.tracks.count)

  //   for (index, track) in tracklist.tracks.enumerated() {
  //     #expect(parsedAgain.tracks[index].time == track.time)
  //     #expect(parsedAgain.tracks[index].artist == track.artist)
  //     #expect(parsedAgain.tracks[index].title == track.title)
  //   }
  // }

  // @Test("Parse CUE file with frames in time")
  // func testParseCueFileWithFrames() {
  //   let cueContent = """
  //     FILE "audio.mp3" WAVE
  //       TRACK 01 AUDIO
  //         TITLE "Track 1"
  //         INDEX 01 00:00:00
  //       TRACK 02 AUDIO
  //         TITLE "Track 2"
  //         INDEX 01 05:30:75
  //     """

  //   let tracklist = CueFile.parse(cueContent)

  //   #expect(tracklist != nil)
  //   #expect(tracklist?.tracks[0].time == "00:00")
  //   #expect(tracklist?.tracks[1].time == "05:30")
  // }
}

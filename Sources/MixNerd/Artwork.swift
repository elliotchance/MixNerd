import AppKit
import ID3TagEditor

struct Artwork {
  var image: NSImage? = nil

  init() {
  }

  init(fromImage image: NSImage) {
    self.image = image
  }

  init(fromURL url: URL) {
    self.image = NSImage(contentsOf: url) ?? NSImage()
  }

  init(fromID3Tag id3Tag: ID3Tag) {
    if let pictureFrame = id3Tag.frames[.attachedPicture(.frontCover)]
      as? ID3FrameAttachedPicture
    {
      let pictureData = pictureFrame.picture
      self.image = NSImage(data: pictureData)
    }
  }

  func jpegData() -> Data {
    if let bits = image?.representations.first as? NSBitmapImageRep {
      return bits.representation(using: .jpeg, properties: [:]) ?? Data()
    }
    return Data()
  }

  func id3FrameAttachedPicture() -> ID3FrameAttachedPicture {
    return ID3FrameAttachedPicture(
      picture: jpegData(),
      type: .frontCover,
      format: .jpeg)
  }

  func write(toFile path: String) {
    let fileURL = URL(fileURLWithPath: path)
    let data = jpegData()
    try? data.write(to: fileURL)
  }
}

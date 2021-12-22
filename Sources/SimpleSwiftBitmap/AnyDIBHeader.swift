//
// Created by Erik Little on 12/22/21.
//

import Foundation

public class AnyDIBHeader {
  @usableFromInline
  var bitsPerPixel: UInt8

  @usableFromInline
  var bitmapSize: UInt32 { header[keyPath: pathToBitmapSize] as! UInt32 }

  @usableFromInline
  var bitmapHeight: Int { Int(header[keyPath: pathToBitmapHeight] as! UInt32) }

  @usableFromInline
  var bitmapWidth: Int { Int(header[keyPath: pathToBitmapWidth] as! UInt32) }

  @usableFromInline
  var header: Any?

  @usableFromInline
  var headerType: Any.Type

  @usableFromInline
  var colorDepth: Int { Int(header[keyPath: pathToColorDepth] as! UInt16) }

  @usableFromInline
  var rawHeaderSize: Int

  @usableFromInline
  var _fromRawBytes: (UnsafeRawPointer) -> Any

  @usableFromInline
  var pathToColorDepth: AnyKeyPath

  @usableFromInline
  var pathToBitmapSize: AnyKeyPath

  @usableFromInline
  var pathToBitmapHeight: AnyKeyPath

  @usableFromInline
  var pathToBitmapWidth: AnyKeyPath

  @usableFromInline
  var pixelMaker: (ArraySlice<UInt8>, Int) -> [Pixel]

  @inlinable
  public init<T: DIBHeader>(for type: T.Type) {
    headerType = type
    _fromRawBytes = T.fromRawBytes
    bitsPerPixel = T.PixelType.bitsPerPixel
    rawHeaderSize = Int(type.rawHeaderSize)
    pathToBitmapSize = \T.bitmapSize
    pathToColorDepth = \T.colorDepth
    pathToBitmapWidth = \T.bitmapWidth
    pathToBitmapHeight = \T.bitmapHeight
    pixelMaker = T.PixelType.loadPixelRow(_:width:)
  }

  @inlinable
  public init<T: DIBHeader>(_ header: T) {
    self.header = header
    headerType = T.self
    _fromRawBytes = T.fromRawBytes
    bitsPerPixel = T.PixelType.bitsPerPixel
    rawHeaderSize = Int(T.rawHeaderSize)
    pathToBitmapSize = \T.bitmapSize
    pathToColorDepth = \T.colorDepth
    pathToBitmapWidth = \T.bitmapWidth
    pathToBitmapHeight = \T.bitmapHeight
    pixelMaker = T.PixelType.loadPixelRow(_:width:)
  }

  @usableFromInline
  func fromRawBytes(_ bytes: UnsafeRawPointer) -> AnyDIBHeader {
    header = _fromRawBytes(bytes)

    return self
  }

  @usableFromInline
  func getRowSizeAndPadding() -> (rowSize: Int, padding: Int) {
    let rowSize = Int(floor(Double(colorDepth * bitmapWidth + 31) / 32.0) * 4)

    return (rowSize, rowSize - Int(bitmapWidth * 3))
  }
}

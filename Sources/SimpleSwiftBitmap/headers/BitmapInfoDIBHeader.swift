//
// Created by Erik Little on 12/20/21.
//

import Foundation

public struct BitmapInfoDIBHeader: DIBHeader {
  public var headerSize: UInt32
  public var bitmapWidth: UInt32
  public var bitmapHeight: UInt32
  public var colorPlane: UInt16
  public var colorDepth: UInt16
  public var compressionMethod: UInt32
  public var bitmapSize: UInt32
  public var horizontalResolution: UInt32
  public var verticalResolution: UInt32
  public var numColors: UInt32
  public var importantColors: UInt32

  public static let rawHeaderSize: UInt32 = 40

  public init(
    headerSize: UInt32,
    bitmapWidth: UInt32,
    bitmapHeight: UInt32,
    colorPlane: UInt16 = 1,
    colorDepth: UInt16,
    compressionMethod: UInt32 = 0,
    bitmapSize: UInt32,
    horizontalResolution: UInt32 = 0,
    verticalResolution: UInt32 = 0,
    numColors: UInt32 = 0,
    importantColors: UInt32 = 0
  ) {
    self.headerSize = headerSize
    self.bitmapWidth = bitmapWidth
    self.bitmapHeight = bitmapHeight
    self.colorPlane = colorPlane
    self.colorDepth = colorDepth
    self.compressionMethod = compressionMethod
    self.bitmapSize = bitmapSize
    self.horizontalResolution = horizontalResolution
    self.verticalResolution = verticalResolution
    self.numColors = numColors
    self.importantColors = importantColors
  }

  public static func fromRawBytes(_ bytes: UnsafeRawPointer) -> BitmapInfoDIBHeader {
    return BitmapInfoDIBHeader(
      headerSize: load32BitFromRaw(pointer: bytes, startingOffset: 0),
      bitmapWidth: load32BitFromRaw(pointer: bytes, startingOffset: 4),
      bitmapHeight: load32BitFromRaw(pointer: bytes, startingOffset: 8),
      colorPlane: load16BitFromRaw(pointer: bytes, startingOffset: 12),
      colorDepth: load16BitFromRaw(pointer: bytes, startingOffset: 14),
      compressionMethod: load32BitFromRaw(pointer: bytes, startingOffset: 16),
      bitmapSize: load32BitFromRaw(pointer: bytes, startingOffset: 20),
      horizontalResolution: load32BitFromRaw(pointer: bytes, startingOffset: 24),
      verticalResolution: load32BitFromRaw(pointer: bytes, startingOffset: 28),
      numColors: load32BitFromRaw(pointer: bytes, startingOffset: 32),
      importantColors: load32BitFromRaw(pointer: bytes, startingOffset: 36)
    )
  }

  public func toRawBytes() -> UnsafeRawPointer {
    let header = UnsafeMutableRawPointer.allocate(byteCount: 40, alignment: 1)

    store32BitToRaw(val: headerSize, pointer: header, startingOffset: 0)
    store32BitToRaw(val: bitmapWidth, pointer: header, startingOffset: 4)
    store32BitToRaw(val: bitmapHeight, pointer: header, startingOffset: 8)
    store16BitToRaw(val: colorPlane, pointer: header, startingOffset: 12)
    store16BitToRaw(val: colorDepth, pointer: header, startingOffset: 14)
    store32BitToRaw(val: compressionMethod, pointer: header, startingOffset: 16)
    store32BitToRaw(val: bitmapSize, pointer: header, startingOffset: 20)
    store32BitToRaw(val: horizontalResolution, pointer: header, startingOffset: 24)
    store32BitToRaw(val: verticalResolution, pointer: header, startingOffset: 28)
    store32BitToRaw(val: numColors, pointer: header, startingOffset: 32)
    store32BitToRaw(val: importantColors, pointer: header, startingOffset: 36)

    return UnsafeRawPointer(header)
  }
}

//
// Created by Erik Little on 12/21/21.
//

import Foundation

public enum ColorSpaceType: UInt32 {
  case calibratedRGB = 0x00000000
  case sRGB = 0x73524742
  case windowsColorSpace = 0x57696E20
}

public enum GamutMappingIntent: UInt32 {
  case absColorimetric = 0x00000008
  case business = 0x00000001
  case graphics = 0x00000002
  case images = 0x00000004
}

public struct ColorSpaceCord {
  public var x: UInt32
  public var y: UInt32
  public var z: UInt32

  public static var `default`: ColorSpaceCord {
    return ColorSpaceCord(x: 0, y: 0, z: 0)
  }

  public static func fromRawBytes(_ bytes: UnsafeRawPointer, offset: Int) -> ColorSpaceCord {
    return ColorSpaceCord(
      x: load32BitFromRaw(pointer: bytes, startingOffset: offset),
      y: load32BitFromRaw(pointer: bytes, startingOffset: offset &+ 4),
      z: load32BitFromRaw(pointer: bytes, startingOffset: offset &+ 8)
    )
  }

  public func storeBytesAt(_ bytes: UnsafeMutableRawPointer, offset: Int) {
    store32BitToRaw(val: x, pointer: bytes, startingOffset: offset)
    store32BitToRaw(val: y, pointer: bytes, startingOffset: offset &+ 4)
    store32BitToRaw(val: z, pointer: bytes, startingOffset: offset &+ 8)
  }
}

public struct ColorSpaceTriple {
  public var r: ColorSpaceCord
  public var g: ColorSpaceCord
  public var b: ColorSpaceCord

  public static var `default`: ColorSpaceTriple {
    return ColorSpaceTriple(r: .default, g: .default, b: .default)
  }

  public static func fromRawBytes(_ bytes: UnsafeRawPointer, offset: Int) -> ColorSpaceTriple {
    return ColorSpaceTriple(
      r: ColorSpaceCord.fromRawBytes(bytes, offset: offset),
      g: ColorSpaceCord.fromRawBytes(bytes, offset: offset &+ 12),
      b: ColorSpaceCord.fromRawBytes(bytes, offset: offset &+ 24)
    )
  }

  public func storeBytesAt(_ bytes: UnsafeMutableRawPointer, offset: Int) {
    r.storeBytesAt(bytes, offset: offset)
    g.storeBytesAt(bytes, offset: offset &+ 12)
    b.storeBytesAt(bytes, offset: offset &+ 24)
  }
}

public struct BitmapInfoDIBHeaderV5: DIBHeader {
  public typealias PixelType = Pixel24

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
  public var redMask: UInt32
  public var blueMask: UInt32
  public var greenMask: UInt32
  public var alphaMask: UInt32
  public var colorSpaceType: ColorSpaceType
  public var colorSpaceTriple: ColorSpaceTriple
  public var gammaRed: UInt32
  public var gammaGreen: UInt32
  public var gammaBlue: UInt32
  public var gamutMapping: GamutMappingIntent
  public var profileData: UInt32
  public var profileSize: UInt32
  public var reserved: UInt32

  public static let rawHeaderSize: UInt32 = 124

//  public init() {
//    headerSize = 0
//    bitmapWidth = 0
//    colorDepth = 1
//    compressionMethod = 0
//    bitmapSize = 0
//    horizontalResolution = 0
//    verticalResolution = 0
//    numColors = 0
//    importantColors = 0
//    redMask = 0
//    greenMask = 0
//    blueMask = 0
//    alphaMask = 0
//    colorSpaceType = .sRGB
//    colorSpaceTriple = .default
//    gammaRed = 0
//    gammaGreen = 0
//    gammaBlue = 0
//    gamutMapping = .images
//    profileData = 0
//    profileSize = 0
//    reserved = 0
//  }

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
    importantColors: UInt32 = 0,
    redMask: UInt32 = 0,
    greenMask: UInt32 = 0,
    blueMask: UInt32 = 0,
    alphaMask: UInt32 = 0,
    colorSpaceType: ColorSpaceType = .calibratedRGB,
    colorSpaceTriple: ColorSpaceTriple = .default,
    gammaRed: UInt32 = 0,
    gammaGreen: UInt32 = 0,
    gammaBlue: UInt32 = 0,
    gamutMapping: GamutMappingIntent = .images,
    profileData: UInt32 = 0,
    profileSize: UInt32 = 0,
    reserved: UInt32 = 0
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
    self.redMask = redMask
    self.greenMask = greenMask
    self.blueMask = blueMask
    self.alphaMask = alphaMask
    self.colorSpaceType = colorSpaceType
    self.colorSpaceTriple = colorSpaceTriple
    self.gammaRed = gammaRed
    self.gammaGreen = gammaGreen
    self.gammaBlue = gammaBlue
    self.gamutMapping = gamutMapping
    self.profileData = profileData
    self.profileSize = profileSize
    self.reserved = reserved
  }

  @inlinable
  public static func fromBitmap<T: BitmapCore>(_ bitmap: T) -> BitmapInfoDIBHeaderV5 {
    return BitmapInfoDIBHeaderV5(
      headerSize: 124,
      bitmapWidth: UInt32(bitmap.width),
      bitmapHeight: UInt32(bitmap.height),
      colorDepth: UInt16(PixelType.bitsPerPixel),
      bitmapSize: rowSize(forWidth: bitmap.width) * UInt32(bitmap.height)
    )
  }

  public static func fromRawBytes(_ bytes: UnsafeRawPointer) -> BitmapInfoDIBHeaderV5 {
    return BitmapInfoDIBHeaderV5(
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
      importantColors: load32BitFromRaw(pointer: bytes, startingOffset: 36),
      redMask: load32BitFromRaw(pointer: bytes, startingOffset: 40),
      greenMask: load32BitFromRaw(pointer: bytes, startingOffset: 44),
      blueMask: load32BitFromRaw(pointer: bytes, startingOffset: 48),
      alphaMask: load32BitFromRaw(pointer: bytes, startingOffset: 52),
      colorSpaceType: ColorSpaceType(rawValue: (load32BitFromRaw(pointer: bytes, startingOffset: 56))) ?? .calibratedRGB,
      colorSpaceTriple: ColorSpaceTriple.fromRawBytes(bytes, offset: 60),
      gammaRed: load32BitFromRaw(pointer: bytes, startingOffset: 96),
      gammaGreen: load32BitFromRaw(pointer: bytes, startingOffset: 100),
      gammaBlue: load32BitFromRaw(pointer: bytes, startingOffset: 104),
      gamutMapping: GamutMappingIntent(rawValue: (load32BitFromRaw(pointer: bytes, startingOffset: 108))) ?? .images,
      profileData: load32BitFromRaw(pointer: bytes, startingOffset: 112),
      profileSize: load32BitFromRaw(pointer: bytes, startingOffset: 116),
      reserved: load32BitFromRaw(pointer: bytes, startingOffset: 120)
    )
  }

  public func storeBytes(_ bytes: UnsafeMutableRawPointer, at offset: Int) {
    store32BitToRaw(val: headerSize, pointer: bytes, startingOffset: offset)
    store32BitToRaw(val: bitmapWidth, pointer: bytes, startingOffset: offset &+ 4)
    store32BitToRaw(val: bitmapHeight, pointer: bytes, startingOffset: offset &+ 8)
    store16BitToRaw(val: colorPlane, pointer: bytes, startingOffset: offset &+ 12)
    store16BitToRaw(val: colorDepth, pointer: bytes, startingOffset: offset &+ 14)
    store32BitToRaw(val: compressionMethod, pointer: bytes, startingOffset: offset &+ 16)
    store32BitToRaw(val: bitmapSize, pointer: bytes, startingOffset: offset &+ 20)
    store32BitToRaw(val: horizontalResolution, pointer: bytes, startingOffset: offset &+ 24)
    store32BitToRaw(val: verticalResolution, pointer: bytes, startingOffset: offset &+ 28)
    store32BitToRaw(val: numColors, pointer: bytes, startingOffset: offset &+ 32)
    store32BitToRaw(val: importantColors, pointer: bytes, startingOffset: offset &+ 36)
    store32BitToRaw(val: redMask, pointer: bytes, startingOffset: offset &+ 40)
    store32BitToRaw(val: greenMask, pointer: bytes, startingOffset: offset &+ 44)
    store32BitToRaw(val: blueMask, pointer: bytes, startingOffset: offset &+ 48)
    store32BitToRaw(val: alphaMask, pointer: bytes, startingOffset: offset &+ 52)
    store32BitToRaw(val: colorSpaceType.rawValue, pointer: bytes, startingOffset: offset &+ 56)
    colorSpaceTriple.storeBytesAt(bytes, offset: 60)
    store32BitToRaw(val: gammaRed, pointer: bytes, startingOffset: offset &+ 96)
    store32BitToRaw(val: gammaGreen, pointer: bytes, startingOffset: offset &+ 100)
    store32BitToRaw(val: gammaBlue, pointer: bytes, startingOffset: offset &+ 104)
    store32BitToRaw(val: gamutMapping.rawValue, pointer: bytes, startingOffset: offset &+ 108)
    store32BitToRaw(val: profileData, pointer: bytes, startingOffset: offset &+ 112)
    store32BitToRaw(val: profileSize, pointer: bytes, startingOffset: offset &+ 116)
    store32BitToRaw(val: reserved, pointer: bytes, startingOffset: offset &+ 120)
  }
}

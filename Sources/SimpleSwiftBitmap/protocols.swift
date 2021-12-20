//
// Created by Erik Little on 12/20/21.
//

import Foundation

public protocol Pixel: Hashable {
  associatedtype BitType: UnsignedInteger

  var r: BitType { get set }
  var g: BitType { get set }
  var b: BitType { get set }

  static var bitsPerPixel: UInt8 { get }

  init(_ r: BitType, _ g: BitType, _ b: BitType)

  static func fromRawBytes(_ bytes: ArraySlice<UInt8>, offset: Int) -> Self
  static func loadPixelRow(_ row: ArraySlice<UInt8>, width: Int) -> [Self]
  func storeRawBytes(_ bytes: UnsafeMutableRawPointer, offset: Int)
}

extension Pixel {
  @inlinable
  public static func loadPixelRow(_ row: ArraySlice<UInt8>, width: Int) -> [Self] {
    let bytesToRead = Int(bitsPerPixel) / 8
    var ret = [Self]()

    assert((row.count).isMultiple(of: bytesToRead))

    ret.reserveCapacity(width)

    for i in stride(from: 0, to: row.count, by: bytesToRead) {
      ret.append(fromRawBytes(row, offset: row.startIndex + i))
    }

    assert(ret.count == width, "Bad row calculations")

    return ret
  }
}

public protocol DIBHeader {
  associatedtype ColorDepthType: UnsignedInteger
  associatedtype BitmapSizeType: UnsignedInteger

  var colorDepth: ColorDepthType { get }
  var bitmapSize: BitmapSizeType { get }
  var bitmapWidth: BitmapSizeType { get }
  var bitmapHeight: BitmapSizeType { get }

  static var rawHeaderSize: BitmapSizeType { get }

  func getRowSizeAndPadding() -> (rowSize: Int, padding: Int)

  static func fromRawBytes(_ bytes: UnsafeRawPointer) -> Self
}

extension DIBHeader {
  @inlinable
  public func getRowSizeAndPadding() -> (rowSize: Int, padding: Int) {
    let rowSize = Int(floor(Double(Int(colorDepth) * Int(bitmapWidth) + 31) / 32.0) * 4)

    return (rowSize, rowSize - Int(bitmapWidth * 3))
  }
}

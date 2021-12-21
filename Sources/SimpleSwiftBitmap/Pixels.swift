//
// Created by Erik Little on 12/20/21.
//

import Foundation

public struct Pixel24: Pixel {
  public var r: UInt8
  public var g: UInt8
  public var b: UInt8
  public var a: UInt8?

  public static let bitsPerPixel: UInt8 = 24

  public init(_ r: UInt8, _ g: UInt8, _ b: UInt8, _ a: UInt8? = nil) {
    self.r = r
    self.g = g
    self.b = b
    self.a = nil
  }

  public static func fromRawBytes(_ bytes: ArraySlice<UInt8>, offset: Int) -> Pixel24 {
    return Pixel24(bytes[offset &+ 2], bytes[offset &+ 1], bytes[offset])
  }

  public func storeBytesAt(_ bytes: UnsafeMutableRawPointer, offset: Int) {
    bytes.storeBytes(of: r, toByteOffset: offset &+ 2, as: UInt8.self)
    bytes.storeBytes(of: g, toByteOffset: offset &+ 1, as: UInt8.self)
    bytes.storeBytes(of: b, toByteOffset: offset, as: UInt8.self)
  }
}

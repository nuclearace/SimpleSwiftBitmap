//
// Created by Erik Little on 12/20/21.
//

import Foundation

public struct BMPHeader {
  public var h1: UInt8
  public var h2: UInt8
  public var bmpSize: UInt32
  public var cust1: UInt16
  public var cust2: UInt16
  public var imageStart: UInt32

  public init(
    h1: UInt8 = ("B" as Character).asciiValue!,
    h2: UInt8 = ("M" as Character).asciiValue!,
    bmpSize: UInt32,
    cust1: UInt16 = 0,
    cust2: UInt16 = 0,
    imageStart: UInt32
  ) {
    self.h1 = h1
    self.h2 = h2
    self.bmpSize = bmpSize
    self.cust1 = cust1
    self.cust2 = cust2
    self.imageStart = imageStart
  }

  @usableFromInline
  static func fromRawBytes(_ bytes: UnsafeRawPointer) -> BMPHeader {
    return BMPHeader(
      h1: bytes.load(fromByteOffset: 0, as: UInt8.self),
      h2: bytes.load(fromByteOffset: 1, as: UInt8.self),
      bmpSize: load32BitFromRaw(pointer: bytes, startingOffset: 2),
      cust1: load16BitFromRaw(pointer: bytes, startingOffset: 6),
      cust2: load16BitFromRaw(pointer: bytes, startingOffset: 8),
      imageStart: load32BitFromRaw(pointer: bytes, startingOffset: 10)
    )
  }

  @usableFromInline
  func storeBytesAt(_ bytes: UnsafeMutableRawPointer, offset: Int = 0) {
    bytes.storeBytes(of: h1, toByteOffset: offset, as: UInt8.self)
    bytes.storeBytes(of: h2, toByteOffset: offset &+ 1, as: UInt8.self)
    store32BitToRaw(val: bmpSize, pointer: bytes, startingOffset: offset &+ 2)
    store16BitToRaw(val: cust1, pointer: bytes, startingOffset: offset &+ 6)
    store16BitToRaw(val: cust2, pointer: bytes, startingOffset: offset &+ 8)
    store32BitToRaw(val: imageStart, pointer: bytes, startingOffset: offset &+ 10)
  }
}

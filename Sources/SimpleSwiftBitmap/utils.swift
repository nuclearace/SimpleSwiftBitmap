//
// Created by Erik Little on 12/20/21.
//

import Foundation

@inline(__always) @_transparent
func store32BitToRaw(val: UInt32, pointer: UnsafeMutableRawPointer, startingOffset: Int) {
  pointer.storeBytes(of: UInt8(val >> 24 & 0xFF), toByteOffset: startingOffset &+ 3, as: UInt8.self)
  pointer.storeBytes(of: UInt8(val >> 16 & 0xFF), toByteOffset: startingOffset &+ 2, as: UInt8.self)
  pointer.storeBytes(of: UInt8(val >> 8 & 0xFF), toByteOffset: startingOffset &+ 1, as: UInt8.self)
  pointer.storeBytes(of: UInt8(val & 0xFF), toByteOffset: startingOffset, as: UInt8.self)
}

@inline(__always) @_transparent
func load32BitFromRaw(pointer: UnsafeRawPointer, startingOffset: Int) -> UInt32 {
  return UInt32(pointer.load(fromByteOffset: startingOffset &+ 3, as: UInt8.self)) << 24 |
      UInt32(pointer.load(fromByteOffset: startingOffset &+ 2, as: UInt8.self)) << 16 |
      UInt32(pointer.load(fromByteOffset: startingOffset &+ 1, as: UInt8.self)) << 8 |
      UInt32(pointer.load(fromByteOffset: startingOffset, as: UInt8.self))
}

@inline(__always) @_transparent
func store16BitToRaw(val: UInt16, pointer: UnsafeMutableRawPointer, startingOffset: Int) {
  pointer.storeBytes(of: UInt8(val >> 8 & 0xFF), toByteOffset: startingOffset &+ 1, as: UInt8.self)
  pointer.storeBytes(of: UInt8(val & 0xFF), toByteOffset: startingOffset, as: UInt8.self)
}

@inline(__always) @_transparent
func load16BitFromRaw(pointer: UnsafeRawPointer, startingOffset: Int) -> UInt16 {
  return UInt16(pointer.load(fromByteOffset: startingOffset &+ 1, as: UInt8.self)) << 8 |
      UInt16(pointer.load(fromByteOffset: startingOffset, as: UInt8.self))
}

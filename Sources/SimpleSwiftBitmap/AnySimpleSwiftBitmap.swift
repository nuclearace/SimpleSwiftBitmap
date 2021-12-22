//
// Created by Erik Little on 12/22/21.
//

import Foundation

public struct AnySimpleSwiftBitmap: BitmapCore {
  public var width: Int { dibHeader.bitmapWidth }
  public var height: Int { dibHeader.bitmapWidth }
  public var pixels: [[Pixel]]

  @usableFromInline
  var header: BMPHeader

  @usableFromInline
  var dibHeader: AnyDIBHeader


  @usableFromInline
  init(header: BMPHeader, dibHeader: AnyDIBHeader, pixels: [[Pixel]]) {
    self.header = header
    self.dibHeader = dibHeader
    self.pixels = pixels
  }

  @inlinable
  public static func fromURL(
    _ url: URL,
    supportedDibs: [AnyDIBHeader] = [
      AnyDIBHeader(for: BitmapInfoDIBHeader.self),
      AnyDIBHeader(for: BitmapInfoDIBHeaderV5.self)
    ]
  ) async throws -> AnySimpleSwiftBitmap {
    let (bytes, _) = try await URLSession.shared.bytes(for: URLRequest(url: url))
    let (header, dibHeader, imageData) = try await extractRawBytes(bytes: bytes, supportedDibs: supportedDibs)
    let pixels = extractImageData(fromData: imageData, dibHeader: dibHeader)

    return AnySimpleSwiftBitmap(header: header, dibHeader: dibHeader, pixels: pixels)
  }

  @usableFromInline
  static func extractRawBytes(
    bytes: URLSession.AsyncBytes,
    supportedDibs: [AnyDIBHeader]
  ) async throws -> (BMPHeader, AnyDIBHeader, [UInt8]) {
    var header: BMPHeader!
    var dibHeader: AnyDIBHeader!
    var headerData = [UInt8]()
    var imageData = [UInt8]()


    consume: for try await byte in bytes {
      guard dibHeader == nil || dibHeader?.header == nil else {
        imageData.append(byte)

        continue
      }

      headerData.append(byte)

      if headerData.count == 14 {
        header = headerData.withUnsafeBytes { BMPHeader.fromRawBytes($0.baseAddress!) }

        for dibType in supportedDibs where header.imageStart - 14 == dibType.rawHeaderSize {
          dibHeader = dibType
          continue consume
        }

        throw BitmapError.unsupportedBitmap
      } else if headerData.count - 14 == dibHeader?.rawHeaderSize ?? .max {
        dibHeader = headerData.withUnsafeBytes { dibHeader.fromRawBytes($0.baseAddress! + 14) }
        imageData.reserveCapacity(Int(dibHeader.bitmapSize))
      }
    }

    guard dibHeader.bitmapSize == imageData.count else {
      throw BitmapError.corruptedFile
    }

    return (header, dibHeader, imageData)
  }

  @usableFromInline
  static func extractImageData(fromData imageData: [UInt8], dibHeader: AnyDIBHeader) -> [[Pixel]] {
    let (rowSize, padding) = dibHeader.getRowSizeAndPadding()
    var pixels = [[Pixel]]()

    pixels.reserveCapacity(dibHeader.bitmapHeight)

    for rowOffset in stride(from: 0, to: imageData.count, by: rowSize) {
      pixels.append(
        dibHeader.pixelMaker(imageData[rowOffset..<rowOffset&+(rowSize&-padding)], Int(dibHeader.bitmapWidth))
      )
    }

    return pixels.reversed()
  }

  @inlinable
  public func save<DIBType: DIBHeader>(to: URL, withDIBType: DIBType.Type) async throws {
    let dib = DIBType.fromBitmap(self)
    let headersSize = DIBType.BitmapSizeType(14 + DIBType.rawHeaderSize)
    let fileSize = dib.bitmapSize + headersSize
    let bmpHeader = BMPHeader(bmpSize: UInt32(fileSize), imageStart: UInt32(headersSize))

    guard let fileBytes = calloc(Int(fileSize), 1) else {
      throw BitmapError.notEnoughMemory
    }

    defer {
      free(fileBytes)
    }

    bmpHeader.storeBytes(fileBytes)
    dib.storeBytes(fileBytes, at: 14)

    let bytesPerPixel = Int(DIBType.PixelType.bitsPerPixel) / 8
    let (rowSize, _) = dib.getRowSizeAndPadding()
    var rowOffset = Int(headersSize)

    for row in pixels.lazy.reversed() {
      for (xOffset, pixel) in row.lazy.enumerated() {
        pixel.storeBytes(fileBytes, at: rowOffset &+ xOffset &* bytesPerPixel)
      }

      rowOffset &+= rowSize
    }

    try await withUnsafeThrowingContinuation {cont  in
      Task.detached {
        do {
          try Data(bytesNoCopy: fileBytes, count: Int(fileSize), deallocator: .none).write(to: to)
          cont.resume()
        } catch {
          cont.resume(throwing: error)
        }
      }
    } as Void
  }
}

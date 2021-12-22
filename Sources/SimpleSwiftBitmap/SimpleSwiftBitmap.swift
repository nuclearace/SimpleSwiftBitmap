//
// Created by Erik Little on 12/20/21.
//

import Foundation

public enum BitmapError: Error {
  case notEnoughMemory
  case unsupportedBitmap
  case unsupportedDib
}

public struct SimpleSwiftBitmap<PixelType, DIBType: DIBHeader>: Bitmap where PixelType == DIBType.PixelType {
  public var header: BMPHeader?
  public var dibHeader: DIBType?
  public var width: Int
  public var height: Int
  public var pixels: [[PixelType]]

  public init(
    header: BMPHeader? = nil,
    dibHeader: DIBType? = nil,
    width: Int,
    height: Int,
    pixels: [[PixelType]]? = nil
  ) {
    self.header = header
    self.dibHeader = dibHeader
    self.width = width
    self.height = height
    self.pixels =
      pixels ??
      [[PixelType]](repeating: [PixelType](repeating: PixelType(0, 0, 0, 0), count: width), count: height)
  }

  @inlinable
  public static func fromURL(_ url: URL) async throws -> SimpleSwiftBitmap {
    let (bytes, _) = try await URLSession.shared.bytes(for: URLRequest(url: url))
    let (header, dibHeader, imageData) = try await extractRawBytes(bytes: bytes)
    let pixels = extractImageData(fromData: imageData, dibHeader: dibHeader)

    return SimpleSwiftBitmap(
      header: header,
      dibHeader: dibHeader,
      width: Int(dibHeader.bitmapWidth),
      height: Int(dibHeader.bitmapHeight),
      pixels: pixels
    )
  }

  @usableFromInline
  static func extractRawBytes(bytes: URLSession.AsyncBytes) async throws -> (BMPHeader, DIBType, [UInt8]) {
    let headersSize = 14 + Int(DIBType.rawHeaderSize)
    var header: BMPHeader!
    var dibHeader: DIBType!
    var headerData = [UInt8]()
    var imageData = [UInt8]()

    headerData.reserveCapacity(headersSize)

    for try await byte in bytes {
      guard dibHeader == nil else {
        imageData.append(byte)

        continue
      }

      headerData.append(byte)

      if headerData.count == 14 {
        header = headerData.withUnsafeBytes { BMPHeader.fromRawBytes($0.baseAddress!) }

        guard header.imageStart - 14 == DIBType.rawHeaderSize else {
          throw BitmapError.unsupportedBitmap
        }
      } else if headerData.count == headersSize {
        dibHeader = headerData.withUnsafeBytes { DIBType.fromRawBytes($0.baseAddress! + 14) }
        imageData.reserveCapacity(Int(dibHeader.bitmapSize))
      }
    }

    assert(dibHeader.bitmapSize == imageData.count, "Missing image data")

    return (header, dibHeader, imageData)
  }

  @usableFromInline
  static func extractImageData(fromData imageData: [UInt8], dibHeader: DIBType) -> [[PixelType]] {
    let (rowSize, padding) = dibHeader.getRowSizeAndPadding()
    var pixels = [[PixelType]]()

    pixels.reserveCapacity(Int(dibHeader.bitmapHeight))

    for rowOffset in stride(from: 0, to: imageData.count, by: rowSize) {
      pixels.append(
        PixelType.loadPixelRow(imageData[rowOffset..<rowOffset+(rowSize-padding)], width: Int(dibHeader.bitmapWidth))
      )
    }

    return pixels.reversed()
  }

  @inlinable
  public mutating func save(to: URL) async throws {
    let dib = DIBType.fromBitmap(self)
    let headersSize = DIBType.BitmapSizeType(14 + DIBType.rawHeaderSize)
    let fileSize = dib.bitmapSize + headersSize
    let bmpHeader = BMPHeader(bmpSize: UInt32(fileSize), imageStart: UInt32(headersSize))
    let bytesPerPixel = Int(PixelType.bitsPerPixel) / 8
    let (rowSize, _) = dib.getRowSizeAndPadding()

    guard let fileBytes = calloc(Int(fileSize), 1) else {
      throw BitmapError.notEnoughMemory
    }

    header = bmpHeader
    dibHeader = dib

    defer {
      free(fileBytes)
    }

    bmpHeader.storeBytesAt(fileBytes)
    dib.storeBytesAt(fileBytes, offset: 14)

    var rowOffset = 0

    for row in pixels.lazy.reversed() {
      for (xOffset, pixel) in row.lazy.enumerated() {
        pixel.storeBytesAt(fileBytes, offset: Int(headersSize) &+ rowOffset &+ xOffset &* bytesPerPixel)
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

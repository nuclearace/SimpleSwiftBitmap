//
// Created by Erik Little on 12/20/21.
//

import Foundation

public enum BitmapError: Error {
  case unsupportedBitmap
  case unsupportedDib
}

public struct SimpleSwiftBitmap<PixelType: Pixel, DIBType: DIBHeader> {
  public private(set) var header: BMPHeader?
  public private(set) var dibHeader: DIBType?
  public private(set) var width: Int
  public private(set) var height: Int
  public private(set) var pixels: [[PixelType]]

  @inlinable
  public var rowSize: Int {
    Int(floor(Double(Int(PixelType.bitsPerPixel) * width + 31) / 32.0) * 4)
  }

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
      [[PixelType]](repeating: [PixelType](repeating: PixelType(0, 0, 0), count: width), count: height)
  }

  @inlinable
  public static func fromFile(_ str: String) async throws -> SimpleSwiftBitmap {
    let (bytes, _) = try await URLSession.shared.bytes(for: URLRequest(url: URL(fileURLWithPath: str)))
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

  @usableFromInline
  func getBMPHeader() -> BMPHeader {
    let imageStart = UInt32(14 + DIBType.rawHeaderSize)

    return BMPHeader(bmpSize: UInt32(rowSize * height) + imageStart, imageStart: imageStart)
  }

  @inlinable
  public func save() async throws {
    let header = getBMPHeader()

    print(header)
  }
}

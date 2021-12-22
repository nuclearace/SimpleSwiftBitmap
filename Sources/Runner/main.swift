//
// Created by Erik Little on 12/20/21.
//

import Foundation
import SimpleSwiftBitmap

typealias BMap = SimpleSwiftBitmap<Pixel24, BitmapInfoDIBHeader>

Task.detached {
  defer {
    exit(0)
  }

  let randomSize = 1203

  let home = FileManager.default.homeDirectoryForCurrentUser
  let mandlebrot = home.appendingPathComponent("/Desktop/mandlebrot.bmp")
  let randomGarbage = home.appendingPathComponent("/Desktop/random.bmp")
  let shinobuOut = home.appendingPathComponent("/Desktop/shinobu.bmp")
  let shinobu = URL(string: "https://drive.google.com/uc?export=view&id=1buKl3t_iNv_jyhv-SSHErEFk7MJ4Xsgl")!

//  var mandleBmp = try await BMap.fromURL(mandlebrot)
//  var randomBmp = BMap(width: randomSize, height: randomSize)

//  print(mandleBmp.pixels.count)
//  print(mandleBmp.header!)
//  print(mandleBmp.dibHeader!)

//  print(bmp.pixels)

//  try await mandleBmp.save(to: mandlebrot)

//  for y in 0..<randomBmp.height {
//    for x in 0..<randomBmp.width {
//      randomBmp.pixels[y][x] = Pixel24(
//        .random(in: (.min)...(.max)),
//        .random(in: (.min)...(.max)),
//        .random(in: (.min)...(.max))
//      )
//    }
//  }
//
//  let s = Date().timeIntervalSince1970
//  try! await randomBmp.save(to: randomGarbage)
//  print("Saving took \(Date().timeIntervalSince1970 - s)")
//
  do {
    var shinobuBmp = try await AnySimpleSwiftBitmap.fromURL(shinobu)

    let s = Date().timeIntervalSince1970
    try await shinobuBmp.save(to: shinobuOut, withDIBType: BitmapInfoDIBHeader.self)
    print("Saving took \(Date().timeIntervalSince1970 - s)")
  } catch {
    print(error)
  }
}

dispatchMain()

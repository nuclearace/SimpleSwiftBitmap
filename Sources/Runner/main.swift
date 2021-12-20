//
// Created by Erik Little on 12/20/21.
//

import Foundation
import SimpleSwiftBitmap

Task.detached {
  defer {
    exit(0)
  }

  let bmp = try await SimpleSwiftBitmap<Pixel24, BitmapInfoDIBHeader>.fromFile(("~/Desktop/mandlebrot.bmp" as NSString).expandingTildeInPath)

  print(bmp.pixels.count)
  print(bmp.header!)
  print(bmp.dibHeader!)

//  print(bmp.pixels)

//  try await bmp.save()
}

dispatchMain()


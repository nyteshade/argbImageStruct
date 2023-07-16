//
//  ARGBImage.swift
//  DMZ
//
//  Created by Brielle Harrison on 7/15/23.
//

import CoreGraphics
import Cocoa

/// `ARGBImage` represents an image in ARGB format and allows access to its raw pixel data.
///
/// This struct provides an abstraction for an image and its ARGB pixel data. It supports
/// initialization from `URL`, `NSImage`, and `CGImage` with optional inclusion of an ARGB header
/// in the pixel data. It also includes a helper function `hexliterals` for creating a hexadecimal
/// representation of the pixel data.
///
/// The ARGB pixel data is stored in a `UInt8` array, where every four elements represent one
/// pixel's ARGB value in the format: Alpha, Red, Green, and Blue. Each value ranges from `0`
/// to `255`.
///
/// Example usage:
/// ```
/// if let argbImage = ARGBImage(url: imageURL, includeHeader: true) {
///     // Prints the ARGB pixel data.
///     print(argbImage.argbPixels)
///
///     // Prints the hexadecimal representation of the pixel data.
///     print(argbImage.hexliterals(varName: "myImagePixels"))
/// }
/// ```
struct ARGBImage: CustomStringConvertible {
  public let image: NSImage
  public let argbPixels: [UInt8]
  
  /// Initializes an `ARGBImage` from a given `NSImage`.
  ///
  /// This initializer attempts to create a `CGImage` from the provided `NSImage`, extracts pixel
  /// data as ARGB bytes, and optionally prepends an ARGB header to the data. If the `NSImage`
  /// cannot be converted to a `CGImage` or if the context cannot be created, the initialization
  /// fails and returns `nil`.
  ///
  /// - Parameters:
  ///   - image: The `NSImage` to convert.
  ///   - includeHeader: If `true`, the ARGB byte data will be prepended with an ARGB header.
  ///     Defaults to `false`.
  public init?(nsImage: NSImage, includeHeader: Bool = false) {
    guard let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
      return nil
    }
    
    self.init(cgImage: cgImage, includeHeader: includeHeader)
  }
  
  /// Initializes an `ARGBImage` by loading an image from a given URL.
  ///
  /// This initializer attempts to create a `CGImage` from the provided URL, extracts pixel data
  /// as ARGB bytes, and optionally prepends an ARGB header to the data. If the image cannot be
  /// loaded or if the context cannot be created, the initialization fails and returns `nil`.
  ///
  /// - Parameters:
  ///   - url: The URL of the image to load.
  ///   - includeHeader: If `true`, the ARGB byte data will be prepended with an ARGB header.
  ///     Defaults to `false`.
  public init?(url: URL, includeHeader: Bool = false) {
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
          let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
      return nil
    }
    
    self.init(cgImage: cgImage, includeHeader: includeHeader)
  }
  
  /// Creates an ARGB image from an NSBitmapImageRep.
  ///
  /// - Parameters:
  ///   - bitmap: The NSBitmapImageRep to load the image from.
  ///   - includeHeader: If `true`, the ARGB pixel data will be prepended with a header.
  ///     Default is `false`.
  public init?(bitmap: NSBitmapImageRep, includeHeader: Bool = false) {
    // Confirm the image is in RGBA format
    guard bitmap.samplesPerPixel == 4 else {
      print("Image is not in RGBA format")
      return nil
    }
    
    self.image = NSImage(size: NSSize(width: bitmap.pixelsWide, height: bitmap.pixelsHigh))
    self.image.addRepresentation(bitmap)
    
    // Prepare ARGB pixel data
    var pixelData = [UInt8](repeating: 0, count: bitmap.pixelsWide * bitmap.pixelsHigh * 4)
    for i in stride(from: 0, to: pixelData.count, by: 4) {
      let x = (i / 4) % bitmap.pixelsWide
      let y = (i / 4) / bitmap.pixelsWide
      
      let rgbaPixel = bitmap.colorAt(x: x, y: y)!
      pixelData[i]     = UInt8(rgbaPixel.alphaComponent * 255) // A
      pixelData[i + 1] = UInt8(rgbaPixel.redComponent * 255)   // R
      pixelData[i + 2] = UInt8(rgbaPixel.greenComponent * 255) // G
      pixelData[i + 3] = UInt8(rgbaPixel.blueComponent * 255)  // B
    }
    
    // Prepend ARGB header
    let argbHeader: [UInt8] = Array("ARGB".utf8)
    if includeHeader {
      self.argbPixels = argbHeader + pixelData
    }
    else {
      self.argbPixels = pixelData
    }
  }
  
  
  /// Initializes an `ARGBImage` from a given `CGImage`.
  ///
  /// This initializer directly takes a `CGImage`, extracts pixel data as ARGB bytes, and
  /// optionally prepends an ARGB header to the data. If the context cannot be created, the
  /// initialization fails and returns `nil`.
  ///
  /// - Parameters:
  ///   - cgImage: The `CGImage` to convert.
  ///   - includeHeader: If `true`, the ARGB byte data will be prepended with an ARGB header.
  ///     Defaults to `false`.
  public init?(cgImage: CGImage, includeHeader: Bool = false) {
    self.image = NSImage(cgImage: cgImage, size: NSZeroSize)
    
    let width = cgImage.width
    let height = cgImage.height
    let bytesPerPixel = cgImage.bitsPerPixel / 8
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard
      let context = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerPixel * width,
        space: colorSpace,
        bitmapInfo:
          CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
      )
    else {
      return nil
    }
    
    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
    
    guard let imageData = context.data else {
      return nil
    }
    
    let data = Data(bytes: imageData, count: height * width * 4)
    var pixelData = [UInt8](repeating: 0, count: width * height * 4)
    data.copyBytes(to: &pixelData, count: pixelData.count)
    
    // Prepend ARGB header
    let argbHeader: [UInt8] = Array("ARGB".utf8)
    if includeHeader {
      self.argbPixels = argbHeader + pixelData
    } else {
      self.argbPixels = pixelData
    }
  }
  
  
  /// Converts an array of `UInt8` elements to a formatted string of hexadecimal literals.
  ///
  /// This function transforms an array of bytes into a formatted string representation where
  /// each byte is presented as a hexadecimal literal. The output can be customized using the
  /// function's parameters.
  ///
  /// - Parameters:
  ///   - varName: Optional. If provided, the output string will begin with a variable declaration
  ///     using this name.
  ///   - perRow: Determines the number of hexadecimal values to include on each line of the
  ///     output string. Default is 16.
  ///   - groupCount: Determines the number of hexadecimal values to group together before adding
  ///     an additional space. Default is 4.
  ///   - groupSpacer: The string to insert between each group of hexadecimal values. Default is
  ///     a single space.
  ///
  /// - Returns: A formatted string of hexadecimal literals representing the array of bytes.
  ///   If `varName` is provided, the string will start with a variable declaration. Each line,
  ///   excluding the first and last, will be indented with two spaces. An extra `groupSpacer`
  ///   will be added after every `groupCount` hexadecimal values, and a newline will be added
  ///   after every `perRow` hexadecimal values.
  public func hexliterals(
    varName: String? = nil,
    perRow: Int = 16,
    groupCount: Int = 4,
    groupSpacer: String = " "
  ) -> String {
    var output = ""
    
    if let varName = varName {
      output += "var \(varName): [UInt8] = "
    }
    
    output += "[\n"
    for (index, byte) in argbPixels.enumerated() {
      if index % perRow == 0 && index != 0 {
        output += "\n"
      }
      if index % groupCount == 0 && index % perRow != 0 {
        output += groupSpacer
      }
      output += "  0x\(String(format: "%02X", byte))"
      if index != argbPixels.count - 1 {
        output += ","
      }
    }
    output += "\n]"
    return output
  }
  
  /// CustomStringConvertible conformance
  ///
  /// Uses the function hexLiterals to output an unnamed variable definition of [UInt8]
  /// pixels. The pixels are arranged in ARGB fashion. This is the equivalent of
  ///
  /// ```
  /// return hexliterals(
  ///   varName: nil,
  ///   perRow: 16,
  ///   groupCount: 4,
  ///   groupSpacer: " "
  /// )
  /// ```
  public var description: String { hexliterals() }
}

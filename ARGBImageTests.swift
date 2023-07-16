//
//  ARGBImageTests.swift
//  DMZTests
//
//  Created by Brielle Harrison on 7/15/23.
//

import Foundation

import XCTest
@testable import DMZ // Replace with your actual module name

class ARGBImageTests: XCTestCase {

  /// Tests that initialization from a URL succeeds when given a valid image URL.
  // func testInitFromURL() {
  //   guard let imageURL = Bundle(for: type(of: self)).url(forResource: "testImage", withExtension: "png") else {
  //     XCTFail("Unable to load test image")
  //     return
  //   }
  //
  //   let argbImage = ARGBImage(url: imageURL)
  //   XCTAssertNotNil(argbImage, "Initialization from URL should succeed for valid image URL")
  // }
  
  /// Tests that initialization from a URL fails when given an invalid image URL.
  func testInitFromInvalidURL() {
    let invalidURL = URL(fileURLWithPath: "/invalid/path/image.png")
    
    let argbImage = ARGBImage(url: invalidURL)
    XCTAssertNil(argbImage, "Initialization from URL should fail for invalid image URL")
  }
  
  /// Tests that the ARGB pixel data is correctly extracted from an NSImage.
  func testPixelDataFromNSImage() {
    // Create a simple 1x1 NSImage with a known color
    let sizeInPixels = NSSize(width: 1, height: 1)
    let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(sizeInPixels.width), pixelsHigh: Int(sizeInPixels.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    NSColor.red.setFill()
    NSBezierPath(rect: NSRect(origin: .zero, size: sizeInPixels)).fill()
    NSGraphicsContext.restoreGraphicsState()

    let image = NSImage(size: sizeInPixels)
    image.addRepresentation(bitmap)
    
    let argbImage = ARGBImage(nsImage: image)
    
    XCTAssertEqual(argbImage?.argbPixels, [255, 255, 0, 0], "ARGB pixel data should be correctly extracted from an NSImage")
  }
  
  func testBitmapImageRepInitializer() {
    // Create a simple 1x1 NSImage with a known color
    let sizeInPixels = NSSize(width: 1, height: 1)
    let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(sizeInPixels.width), pixelsHigh: Int(sizeInPixels.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    NSColor.red.setFill()
    NSBezierPath(rect: NSRect(origin: .zero, size: sizeInPixels)).fill()
    NSGraphicsContext.restoreGraphicsState()

    let image = NSImage(size: sizeInPixels)
    image.addRepresentation(bitmap)
    image.lockFocus()
    NSColor.red.setFill()
    NSBezierPath(rect: NSRect(origin: .zero, size: sizeInPixels)).fill()
    image.unlockFocus()
    
    guard let argbImage = ARGBImage(bitmap: bitmap) else {
      XCTFail("ARGBImage initialization with NSBitmapImageRep failed")
      return
    }
    
    // Check that the dimensions of the ARGBImage match the input bitmap's
    XCTAssertEqual(argbImage.image.size.width, sizeInPixels.width, accuracy: 0.0001)
    XCTAssertEqual(argbImage.image.size.height, sizeInPixels.height, accuracy: 0.0001)
    
    // Check that the pixel data is correct (ARGB values for red color)
    XCTAssertEqual(argbImage.argbPixels, [0xFF, 0xFF, 0x00, 0x00])
  }
}

# ARGBImage

ARGBImage is a Swift struct designed to provide a pixel-level representation of images using ARGB color format in macOS. It provides several initializers to create an ARGB image from various types such as NSImage, CGImage, URL, and NSBitmapImageRep. Each pixel is represented by 4 UInt8 values corresponding to the Alpha, Red, Green, and Blue components.

This package is useful when precise pixel manipulation is required, such as in image processing, computer vision tasks, and testing graphical output.

## Usage
Here's an example of creating an ARGBImage from an NSImage:

```swift
let nsImage = NSImage(named: NSImage.Name("your_image"))
let argbImage = ARGBImage(image: nsImage)
```

Or from a URL:

```swift
let imageURL = URL(fileURLWithPath: "/path/to/your/image.png")
let argbImage = ARGBImage(url: imageURL)
```

Or from a CGImage:

```swift
let cgImage = ... // Obtain a CGImage somehow
let argbImage = ARGBImage(cgImage: cgImage)
```

Or from a NSBitmapImageRep:

```swift
let bitmapImageRep = ... // Obtain a NSBitmapImageRep somehow
let argbImage = ARGBImage(bitmap: bitmapImageRep)
```

You can access the raw ARGB pixels like this:

```swift
let pixels = argbImage.argbPixels
```

You can also generate a string representation of the pixel data using the hexliterals() function:

```swift
let hexPixelData = argbImage.hexliterals(perRow: 16, groupCount: 4)
print(hexPixelData)
```

## Testing
This package includes a set of unit tests for the ARGBImage struct. These tests cover all the initializers, confirming that they correctly interpret pixel data from the input images.

To run the tests, use Xcode's test navigator or the swift test command if you're using the Swift Package Manager.

## Requirements

* macOS 10.15+
* Swift 5.1+

## Contributing
Contributions to improve ARGBImage are welcome. Please open a GitHub issue to discuss your proposed changes before submitting a pull request.

## License
This project is licensed under the terms of the MIT license. See the LICENSE file for more information.

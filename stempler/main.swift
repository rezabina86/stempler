
import Foundation

let STEMPLER_VERSION: String = "0.1.2";

enum IconPosition: Int {
    case topLeft = 0
    case topRight
    case bottomLeft
    case bottomRight
}

func logError(_ err: String) {
    fputs("ERROR: " + err, stderr);
}

func logWarning(_ warn: String) {
    fputs("WARNING: " + warn, stderr);
}

func logInfo(_ msg: String) {
    print(msg)
}

func uttypeFromFileName(_ name: String) -> CFString? {
    let ext: String = (name as NSString).pathExtension.lowercased()
    let map: [String: CFString] = [
        "jpeg": kUTTypeJPEG,
        "jpg": kUTTypeJPEG,
        "png": kUTTypePNG,
        "bmp": kUTTypeBMP ]
    return map[ext]
}

func saveImage(_ image: CGImage, path: String, quality: Double) -> Bool {
    let options: [String:AnyObject] = [
        kCGImagePropertyOrientation as String : 1 as AnyObject,
        kCGImagePropertyHasAlpha as String : true as AnyObject,
        kCGImageDestinationLossyCompressionQuality as String : quality/100 as AnyObject]
    let url = URL(fileURLWithPath: path, isDirectory: false)
    let imageType = uttypeFromFileName(path)
    if nil == imageType {
        logError("cannot determine image type")
        return false
    }
    let file = CGImageDestinationCreateWithURL(url as CFURL, imageType!, 1, nil);
    if nil == file {
        logError("cannot open output file")
        return false
    }
    CGImageDestinationAddImage(file!, image, options as CFDictionary?)
    if !CGImageDestinationFinalize(file!) {
        logError("cannot generate output file")
        return false
    }
    return true
}

func loadImage(_ path : String) -> CGImage? {
    let url: CFURL = URL(fileURLWithPath: path, isDirectory: false) as CFURL
    let imgSrc: CGImageSource? = CGImageSourceCreateWithURL(url, nil)
    if nil == imgSrc {
        logError("cannot open input image")
        return nil
    }
    let result: CGImage? = CGImageSourceCreateImageAtIndex(imgSrc!, 0, nil)
    if nil == result {
        logError("cannot read (first) input image")
    }
    return result
}

func createBitmapContext(_ width: Int, _ height: Int) -> CGContext? {
    let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(
        data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
    context!.interpolationQuality = CGInterpolationQuality.high
    return context
}

func render(_ img: CGImage, width: Int, height: Int, icon: CGImage, x: Int, y: Int,
            iconWidth: Int, iconHeight: Int, opacity: Double) -> CGImage? {
    
    // draw the main image, using the given size
    let size = CGSize(width: width, height: height)
    let rect = CGRect(origin: CGPoint.zero, size: size)
    let context: CGContext = createBitmapContext(width, height)!
    context.draw(img, in: rect)
    
    // draw the icon
    let sizeIcon = CGSize(width: iconWidth, height: iconHeight)
    let rectIcon = CGRect(origin: CGPoint(x: x, y: y), size: sizeIcon)
    context.setAlpha(CGFloat(opacity / 100))
    context.draw(icon, in: rectIcon)
    
    // create the new image
    let result = context.makeImage()
    return result
}

func calc(_ imgWidth: Int, imgHeight: Int, iconWidth: Int, iconHeight: Int,
          pixels: Int, iconPct: Double, margin: Double, position: IconPosition,
          w: inout Int, h: inout Int, x: inout Int, y: inout Int, iw: inout Int, ih: inout Int,
          iconUpscale: inout Bool) {
    
    // calculate the target image size
    let resizeFactor = sqrt(Double(imgWidth * imgHeight) / Double(pixels))
    let resize = resizeFactor > 1
    if (resize) {
        w = Int(Double(imgWidth) / resizeFactor)
        h = Int(Double(imgHeight) / resizeFactor)
    } else {
        w = imgWidth
        h = imgHeight
    }
    
    // calculate the icon size
    let iconPixels = Int((Double(w * h) * iconPct) / 100.0)
    let resizeFactorIcon = sqrt(Double(iconWidth * iconHeight) / Double(iconPixels))
    iconUpscale = resizeFactorIcon < 1
    iw = Int(Double(iconWidth) / resizeFactorIcon)
    ih = Int(Double(iconHeight) / resizeFactorIcon)
    
    // determine the gap of the icon
    let gap = Int((Double(min(iw, ih)) * margin) / 100.0)
    
    // place the icon
    switch position {
    case IconPosition.topLeft:
        x = gap
        y = h - gap - ih
    case IconPosition.topRight:
        x = w - gap - iw
        y = h - gap - ih
    case IconPosition.bottomLeft:
        x = gap
        y = gap
    case IconPosition.bottomRight:
        x = w - gap - iw
        y = gap
    }
}

func run(_ inFile : String, iconFile: String,
         pixels: Int, iconPct: Double, margin: Double, position: IconPosition, opacity: Double, quality: Double,
         outFile: String) -> Int32 {
    let img: CGImage = loadImage(inFile)!
    let icon: CGImage = loadImage(iconFile)!
    let imgWidth = img.width
    var x: Int = -1
    var y: Int = -1
    var w: Int = -1
    var h: Int = -1
    var iw: Int = -1
    var ih: Int = -1
    var iconUpscale: Bool = false
    calc(img.width,
         imgHeight: img.height,
         iconWidth: icon.width,
         iconHeight: icon.height,
         pixels: pixels, iconPct: iconPct, margin: margin, position: position,
         w: &w, h: &h, x: &x, y: &y, iw: &iw, ih: &ih, iconUpscale: &iconUpscale)
    if iconUpscale {
        logWarning("WARNING: icon needs upscaling")
    }
    if (imgWidth < w) {
        logWarning("WARNING: image won't be made smaller")
    }
    let rendered: CGImage = render(img, width: w, height: h, icon: icon, x: x, y: y,
                                   iconWidth: iw, iconHeight: ih, opacity: opacity)!
    if saveImage(rendered, path: outFile, quality: quality) {
        logInfo("image \(w)x\(h) saved with icon \(iw)x\(ih)")
    }
    return 0
}

if CommandLine.arguments.count < 10 {
    print("Stempler " + STEMPLER_VERSION + "\n\n" +
        "usage: stempler [in] [icon] [pixels] [icon-pct] [margin] [position(0..3)]\n" +
        "                [opacity] [quality] [out]\n\n" +
        "example: stempler test.png icon.png 100000 5.0 50.0 3 75.0 90.0 out.jpg\n")
    exit(1)
}
else {
    let exitCode: Int32 = run(
        CommandLine.arguments[1],
        iconFile :                            CommandLine.arguments[2],
        pixels   : Int         (              CommandLine.arguments[3])!,
        iconPct  : Double      (              CommandLine.arguments[4])!,
        margin   : Double      (              CommandLine.arguments[5])!,
        position : IconPosition(rawValue: Int(CommandLine.arguments[6])!)!,
        opacity  : Double      (              CommandLine.arguments[7])!,
        quality  : Double      (              CommandLine.arguments[8])!,
        outFile  :                            CommandLine.arguments[9]);
    exit(exitCode)
}

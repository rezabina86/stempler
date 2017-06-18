# Stempler - Fair Image Watermarking

Stempler takes an image and places a watermark into a specific corner, while also scaling it down
to a given number of pixels. The size of the watermark is proportinal to the actual image size,
meaning independent from the aspect ratio you will always end up with the same number of pixels
for both the image and the watermark itself.

This fair treatment avoids problems with watermarks appearing too large or too small, or square
images ending up bigger than ones with higher aspect ratio. All in all the consumer always gets
a fair amount across all images you ship.

The software runs under macOS and uses Core Graphics for all things rendering at the highest
quality, so you end up with the best results possible. Both images and watermarks can either be
PNG, JPEG or BMP. Opacity is supported for the watermarks being drawn.

## Usage

In the console all parameters for the conversion must be provided:

```stempler [in] [icon] [pixels] [icon-pct] [margin] [position] [opacity] [quality] [out]```

### in

The input file, either in PNG, JPEG or BMP format. Notice that images will be downscaled to the given pixel count, but never upscaled.

### icon

The watermark icon file. Will be scaled down, if upscaling is needed a warning will be printed. It is recommended to have a large enough icon, so upscaling is never needed. Supported icon formats are also PNG, JPEG or BMP.

### pixels

The pixel count the output image should have. The final number of pixels might be a bit less, based on the image width. If e.g. you pass 1000000 (1 megapixel) a square image will end up to be 1000x1000, while a panorama-like image could end with something like 2500x400.

### icon-pct

Percentage the watermark icon should cover in the final image. This is usually a small, single digit number.

### margin

The distance of the icon from the borders of the image. Passed in as a percentage of the smaller side of the icon file. So if the icon file e.g. would end up with 100x150 pixels, and margin is set to 50, the gap would then be 100 (the smaller side) x 50/100 = 50 pixels.

### position

In which corner to place the icon. 0 for top-left, 1 for top-right, 2 for bottom-left and 3 for bottom-right.

### opacity

Percentage of the transparency level the icon should have. 0 for full (icon will be invisible) and 100 for full opacity.

### quality

Quality of the JPEG image, from 1 (lowest) to 100 (highest). Ignored for other formats.

### out

Name and path of the output file.

## Example

```stempler test.png mark.png 1000000 2.5 50 3 75.0 90.0 final.jpg```

Assume the file _test.png_ is square. It will be resized to _1000000_ pixels, or a 1000x1000 resolution respectively. The icon file _mark.png_ is also square and 500x500 large. Since _2.5_ is given it will end up to occupying 25,000 pixels, with a size of 158x158. The icon will have a distance of 79 pixels from the borders (_50_ percent of 158) and placed at position _3_, the bottom-right corner. 25% of the original image will be shining through it, since opacity is set to _75_. The output image _final.jpg_ will end up be stored with a quality setting of _90_.

All in all it is recommended to experiment with the settings, until you get the results you like best.

## Building

Open Xcode, load the project, run the test cases, then build the binary of your choice.

Current environment for development:
* Xcode 8.3.3
* macOS 10.12.5


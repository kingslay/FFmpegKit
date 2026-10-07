# FFmpegKit ![GitHub release](https://img.shields.io/badge/release-v5.1-blue.svg) ![CocoaPods](https://img.shields.io/cocoapods/v/ffmpeg-kit-ios-min) 

`FFmpegKit` is a collection of tools to use `FFmpeg` in `iOS`, `macOS`, `tvOS`, `xrOS`, `visionOS`  applications.

## Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/kingslay/FFmpegKit.git", .branch("main"))
]
```

## License
FFmpegKit uses the GPL license.
 
Additionally, there is a paid version that adopts the LGPL license (contact us).  

## LGPL version Features
- Scripts to build FFmpeg、MPV native libraries
- Run ffmpeg ffprobe in code


### Build Scripts
```bash
swift package BuildFFmpeg -h
swift package --disable-sandbox BuildFFmpeg

swift run ffplay
swift run ffmpegCmd
swift run ffprobeCmd

```

### Run ffmpeg ffprobe in code

```swift
var arguments = ["ffmpeg", "-i", "file1.mp4", "-c:v", "mpeg4", "file2.mp4"]
var argv = arguments.map {
    UnsafeMutablePointer(mutating: ($0 as NSString).utf8String)
}
ffmpeg_execute(Int32(arguments.count), &argv)

arguments = ["ffprobe", "-h"]
argv = arguments.map {
    UnsafeMutablePointer(mutating: ($0 as NSString).utf8String)
}
ffprobe_execute(Int32(arguments.count), &argv)
```

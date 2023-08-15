# FFmpegKit ![GitHub release](https://img.shields.io/badge/release-v5.1-blue.svg) ![CocoaPods](https://img.shields.io/cocoapods/v/ffmpeg-kit-ios-min) 

`FFmpegKit` is a collection of tools to use `FFmpeg` in `iOS`, `macOS`, `tvOS`, `xrOS`, `visionOS`  applications.

It includes scripts to build `FFmpeg` native libraries, three executable product `ffplay`/`ffmpeg`/`ffprobe` in macos

### Features
- Scripts to build FFmpeg native libraries
- three executable product `ffplay`/`ffmpeg`/`ffprobe` in macos
- Supports native platforms: `iOS`, `macOS`, `tvOS`, `xrOS`, `visionOS`
- Build MPV

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/kingslay/FFmpegKit.git", .branch("main"))
]
// mpv
dependencies: [
    .package(url: "https://github.com/kingslay/FFmpegKit.git", .branch("mpv"))
]
```

## Build Scripts
```bash
swift package BuildFFmpeg --disable-sandbox enable-libdav1d enable-openssl enable-libsrt
```
## Executable product
```bash
swift run ffplay
swift run ffmpeg
swift run ffprobe
```
## Help 
```bash
swift package BuildFFmpeg h
```

```bash
Usage: swift package BuildFFmpeg [OPTION]...
Demo: swift package BuildFFmpeg --disable-sandbox enable-libdav1d enable-openssl enable-libsrt
Options:
    h                   display this help and exit
    enable-debug,       build ffmpeg with debug information
    disable-ffmpeg      no build ffmpeg [no]
    platforms=xros      deployment platform: ios,isimulator,tvos,tvsimulator,macos,maccatalyst,xros,xrsimulator,watchos,watchsimulator,
    --xx                add ffmpeg Configuers
    --disable-sandbox   spm disable sanbox

Libraries:
    enable-libdav1d     build with dav1d [no]
    enable-openssl      build with openssl [no]
    enable-libsrt       depend enable-openssl
    enable-libfreetype  depend enable-png
    enable-libass       depend enable-png enable-libfreetype enable-libfribidi enable-harfbuzz
    enable-nettle       depend enable-gmp
    enable-gnutls       depend enable-gmp enable-nettle
    enable-libsmbclient depend enable-gmp enable-nettle enable-gnutls
    enable-harfbuzz     depend enable-libfreetype
    enable-mpv          depend enable-libfreetype enable-libfribidi enable-harfbuzz enable-libass
```

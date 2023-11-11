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
swift package --disable-sandbox BuildFFmpeg

/// build MPV
swift package --disable-sandbox BuildFFmpeg enable-libdav1d enable-openssl enable-libsrt enable-libzvbi enable-png enable-libfreetype enable-libfribidi enable-harfbuzz enable-libass enable-FFmpeg enable-mpv platforms=macos
```
## Executable product
```bash
swift run ffplay
swift run ffmpeg
swift run ffprobe
```
## Help 
```bash
swift package BuildFFmpeg -h
```

```bash
Usage: swift package BuildFFmpeg [OPTION]...
Default Build: swift package --disable-sandbox BuildFFmpeg enable-libdav1d enable-openssl enable-libsrt enable-FFmpeg
Build MPV: swift package --disable-sandbox BuildFFmpeg mpv or swift package --disable-sandbox BuildFFmpeg enable-libdav1d enable-openssl enable-libsrt enable-png enable-libfreetype enable-libfribidi enable-harfbuzz enable-libass enable-FFmpeg enable-mpv
Options:
    h, -h, --help       display this help and exit
    enable-debug,       build ffmpeg with debug information
    platforms=xros      deployment platform: ios,isimulator,tvos,tvsimulator,macos,maccatalyst,xros,xrsimulator,watchos,watchsimulator,
    --xx                add ffmpeg Configuers
    mpv                 build mpv

Libraries:
    enable-libdav1d     build with dav1d
    enable-openssl      build with openssl
    enable-libsrt       depend enable-openssl
    enable-libfreetype  depend enable-png [no]
    enable-libass       depend enable-png enable-libfreetype enable-libfribidi enable-harfbuzz [no]
    enable-nettle       depend enable-gmp [no]
    enable-gnutls       depend enable-gmp enable-nettle [no]
    enable-libsmbclient depend enable-gmp enable-nettle enable-gnutls [no]
    enable-harfbuzz     depend enable-libfreetype [no]
    enable-FFmpeg       build with FFmpeg
    enable-mpv          depend enable-png enable-libfreetype enable-libfribidi enable-harfbuzz enable-libass [no]
```
